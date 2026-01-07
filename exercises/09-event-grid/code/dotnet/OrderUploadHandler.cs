using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace CloudShop.Functions;

/// <summary>
/// Handles Event Grid events for blob uploads in the orders container.
/// Reads the blob content and logs each order found in batch files.
/// </summary>
public class OrderUploadHandler
{
    private readonly ILogger<OrderUploadHandler> _logger;

    public OrderUploadHandler(ILogger<OrderUploadHandler> logger)
    {
        _logger = logger;
    }

    [Function("OrderUploaded")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options")] HttpRequestData req)
    {
        // Handle CloudEvents validation (OPTIONS request)
        if (req.Method.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
        {
            var optionsResponse = req.CreateResponse(HttpStatusCode.OK);
            var origin = req.Headers.TryGetValues("WebHook-Request-Origin", out var values)
                ? values.FirstOrDefault() ?? "*"
                : "*";
            optionsResponse.Headers.Add("WebHook-Allowed-Origin", origin);
            return optionsResponse;
        }

        try
        {
            var requestBody = await req.ReadAsStringAsync();
            if (string.IsNullOrEmpty(requestBody))
            {
                return req.CreateResponse(HttpStatusCode.BadRequest);
            }

            var events = ParseEvents(requestBody);

            foreach (var evt in events)
            {
                var eventType = evt.GetProperty("eventType").GetString() ?? "";

                // Handle subscription validation
                if (eventType == "Microsoft.EventGrid.SubscriptionValidationEvent")
                {
                    var validationCode = evt.GetProperty("data")
                        .GetProperty("validationCode")
                        .GetString();

                    _logger.LogInformation("Event Grid validation request. Code: {Code}", validationCode);

                    var validationResponse = req.CreateResponse(HttpStatusCode.OK);
                    validationResponse.Headers.Add("Content-Type", "application/json");
                    await validationResponse.WriteStringAsync(
                        JsonSerializer.Serialize(new { validationResponse = validationCode }));
                    return validationResponse;
                }

                // Handle blob created event
                if (eventType == "Microsoft.Storage.BlobCreated")
                {
                    await ProcessBlobCreatedEvent(evt);
                }
                else
                {
                    _logger.LogInformation("Unhandled event type: {EventType}", eventType);
                }
            }

            return req.CreateResponse(HttpStatusCode.OK);
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "Invalid JSON in Event Grid request");
            return req.CreateResponse(HttpStatusCode.BadRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Event Grid event");
            return req.CreateResponse(HttpStatusCode.InternalServerError);
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

    private async Task ProcessBlobCreatedEvent(JsonElement evt)
    {
        var data = evt.GetProperty("data");
        var subject = evt.GetProperty("subject").GetString() ?? "";
        var blobUrl = data.GetProperty("url").GetString() ?? "";

        // Extract blob name from subject
        var blobName = subject.Contains("/blobs/")
            ? subject.Split("/blobs/").Last()
            : "unknown";

        _logger.LogInformation("=== ORDER BATCH UPLOADED ===");
        _logger.LogInformation("Event ID: {EventId}", evt.GetProperty("id").GetString());
        _logger.LogInformation("Blob: {BlobName}", blobName);

        // Read and parse the blob content
        var orders = await ReadOrdersFromBlob(blobUrl);

        if (orders.Count == 0)
        {
            _logger.LogWarning("No orders found in blob {BlobName}", blobName);
            return;
        }

        _logger.LogInformation("Found {OrderCount} orders in batch", orders.Count);
        _logger.LogInformation("---");

        foreach (var order in orders)
        {
            _logger.LogInformation("  Order: {OrderId} | Customer: {Customer} | Total: ${Total:F2}",
                order.Id ?? order.OrderId ?? "N/A",
                order.Customer ?? "Unknown",
                order.Total);
        }

        _logger.LogInformation("---");
        _logger.LogInformation("Batch processing complete. Orders ready for Service Bus (Exercise 10).");
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
