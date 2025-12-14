using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace CloudShopEventGrid;

public class OrderProcessor
{
    private readonly ILogger<OrderProcessor> _logger;

    public OrderProcessor(ILogger<OrderProcessor> logger)
    {
        _logger = logger;
    }

    [Function("OrderUploaded")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options")] HttpRequestData req)
    {
        _logger.LogInformation("Event Grid trigger received a request");

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

            // Parse events (can be single or array)
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

                    _logger.LogInformation($"Validation request received. Code: {validationCode}");

                    var validationResponse = req.CreateResponse(HttpStatusCode.OK);
                    validationResponse.Headers.Add("Content-Type", "application/json");
                    await validationResponse.WriteStringAsync(
                        JsonSerializer.Serialize(new { validationResponse = validationCode }));
                    return validationResponse;
                }

                // Handle blob created event
                if (eventType == "Microsoft.Storage.BlobCreated")
                {
                    ProcessBlobCreatedEvent(evt);
                }
                else
                {
                    _logger.LogInformation($"Unhandled event type: {eventType}");
                }
            }

            return req.CreateResponse(HttpStatusCode.OK);
        }
        catch (JsonException ex)
        {
            _logger.LogError($"Invalid JSON in request: {ex.Message}");
            return req.CreateResponse(HttpStatusCode.BadRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error processing event: {ex.Message}");
            return req.CreateResponse(HttpStatusCode.InternalServerError);
        }
    }

    private List<JsonElement> ParseEvents(string requestBody)
    {
        using var doc = JsonDocument.Parse(requestBody);
        var root = doc.RootElement;

        if (root.ValueKind == JsonValueKind.Array)
        {
            return root.EnumerateArray().ToList();
        }

        return new List<JsonElement> { root.Clone() };
    }

    private void ProcessBlobCreatedEvent(JsonElement evt)
    {
        var data = evt.GetProperty("data");
        var subject = evt.GetProperty("subject").GetString() ?? "";

        _logger.LogInformation(new string('=', 50));
        _logger.LogInformation("ORDER FILE UPLOADED");
        _logger.LogInformation(new string('=', 50));
        _logger.LogInformation($"Event ID: {evt.GetProperty("id").GetString()}");
        _logger.LogInformation($"Event Time: {evt.GetProperty("eventTime").GetString()}");
        _logger.LogInformation($"Subject: {subject}");
        _logger.LogInformation($"Blob URL: {data.GetProperty("url").GetString()}");
        _logger.LogInformation($"Content Type: {GetPropertyOrDefault(data, "contentType", "unknown")}");
        _logger.LogInformation($"Content Length: {GetPropertyOrDefault(data, "contentLength", "0")} bytes");
        _logger.LogInformation($"API: {GetPropertyOrDefault(data, "api", "unknown")}");
        _logger.LogInformation(new string('=', 50));

        // Extract blob name from subject
        var blobName = subject.Contains("/blobs/")
            ? subject.Split("/blobs/").Last()
            : "unknown";

        _logger.LogInformation($"Processing order file: {blobName}");
        _logger.LogInformation($"Order file {blobName} would be processed and forwarded to Service Bus");
    }

    private string GetPropertyOrDefault(JsonElement element, string propertyName, string defaultValue)
    {
        return element.TryGetProperty(propertyName, out var prop)
            ? prop.ToString()
            : defaultValue;
    }
}
