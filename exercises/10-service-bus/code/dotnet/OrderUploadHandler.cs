using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace CloudShop.Functions;

/// <summary>
/// Handles Event Grid events for blob uploads in the orders container.
/// Reads batch files and fans out each order as a separate Service Bus message.
/// </summary>
public class OrderUploadHandler
{
    private readonly ILogger<OrderUploadHandler> _logger;

    public OrderUploadHandler(ILogger<OrderUploadHandler> logger)
    {
        _logger = logger;
    }

    [Function("OrderUploaded")]
    [ServiceBusOutput("orders", Connection = "ServiceBusConnection")]
    public async Task<List<OrderMessage>> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options")] HttpRequestData req)
    {
        var messages = new List<OrderMessage>();

        // Handle CloudEvents validation (OPTIONS request)
        if (req.Method.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
        {
            var optionsResponse = req.CreateResponse(HttpStatusCode.OK);
            var origin = req.Headers.TryGetValues("WebHook-Request-Origin", out var values)
                ? values.FirstOrDefault() ?? "*"
                : "*";
            optionsResponse.Headers.Add("WebHook-Allowed-Origin", origin);
            return messages; // Empty list, no messages to queue
        }

        try
        {
            var requestBody = await req.ReadAsStringAsync();
            if (string.IsNullOrEmpty(requestBody))
            {
                return messages;
            }

            var events = ParseEvents(requestBody);

            foreach (var evt in events)
            {
                var eventType = evt.GetProperty("eventType").GetString() ?? "";

                // Handle subscription validation - no Service Bus messages
                if (eventType == "Microsoft.EventGrid.SubscriptionValidationEvent")
                {
                    _logger.LogInformation("Event Grid validation request received");
                    return messages; // Validation handled separately via HTTP response
                }

                // Handle blob created event - fan out to Service Bus
                if (eventType == "Microsoft.Storage.BlobCreated")
                {
                    var orderMessages = await ProcessBlobCreatedEvent(evt);
                    messages.AddRange(orderMessages);
                }
            }

            return messages;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Event Grid event");
            return messages;
        }
    }

    private List<JsonElement> ParseEvents(string requestBody)
    {
        using var doc = JsonDocument.Parse(requestBody);
        var root = doc.RootElement;

        if (root.ValueKind == JsonValueKind.Array)
        {
            return root.EnumerateArray().Select(e => e.Clone()).ToList();
        }

        return new List<JsonElement> { root.Clone() };
    }

    private async Task<List<OrderMessage>> ProcessBlobCreatedEvent(JsonElement evt)
    {
        var messages = new List<OrderMessage>();

        var data = evt.GetProperty("data");
        var subject = evt.GetProperty("subject").GetString() ?? "";
        var blobUrl = data.GetProperty("url").GetString() ?? "";

        var blobName = subject.Contains("/blobs/")
            ? subject.Split("/blobs/").Last()
            : "unknown";

        _logger.LogInformation("=== ORDER BATCH UPLOADED ===");
        _logger.LogInformation("Blob: {BlobName}", blobName);

        // Read and parse the blob content
        var orders = await ReadOrdersFromBlob(blobUrl);

        if (orders.Count == 0)
        {
            _logger.LogWarning("No orders found in blob {BlobName}", blobName);
            return messages;
        }

        _logger.LogInformation("Found {OrderCount} orders - fanning out to Service Bus", orders.Count);

        // Create a Service Bus message for each order
        foreach (var order in orders)
        {
            var orderId = order.Id ?? order.OrderId ?? Guid.NewGuid().ToString();

            var message = new OrderMessage
            {
                OrderId = orderId,
                Order = order,
                Source = "BlobUpload",
                BlobUrl = blobUrl,
                BlobName = blobName,
                QueuedAt = DateTime.UtcNow
            };

            messages.Add(message);
            _logger.LogInformation("  Queued: {OrderId} | Customer: {Customer} | Total: ${Total:F2}",
                orderId, order.Customer ?? "Unknown", order.Total);
        }

        _logger.LogInformation("Sent {MessageCount} messages to Service Bus queue", messages.Count);
        return messages;
    }

    private async Task<List<Order>> ReadOrdersFromBlob(string blobUrl)
    {
        try
        {
            // Get storage connection from environment
            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            if (string.IsNullOrEmpty(connectionString))
            {
                _logger.LogError("AzureWebJobsStorage connection string not configured");
                return new List<Order>();
            }

            // Parse the blob URL to get container and blob name
            var uri = new Uri(blobUrl);
            var pathParts = uri.AbsolutePath.TrimStart('/').Split('/', 2);
            if (pathParts.Length < 2)
            {
                _logger.LogError("Invalid blob URL format: {BlobUrl}", blobUrl);
                return new List<Order>();
            }

            var containerName = pathParts[0];
            var blobName = pathParts[1];

            // Download blob content
            var blobServiceClient = new BlobServiceClient(connectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            var response = await blobClient.DownloadContentAsync();
            var content = response.Value.Content.ToString();

            // Parse JSON - handle both array and single object
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };

            if (content.TrimStart().StartsWith('['))
            {
                return JsonSerializer.Deserialize<List<Order>>(content, options) ?? new List<Order>();
            }
            else
            {
                var singleOrder = JsonSerializer.Deserialize<Order>(content, options);
                return singleOrder != null ? new List<Order> { singleOrder } : new List<Order>();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reading orders from blob");
            return new List<Order>();
        }
    }
}
