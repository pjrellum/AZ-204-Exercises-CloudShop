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

        // TODO 1: Handle CloudEvents validation (OPTIONS request)
        // Hint: Return 200 OK with WebHook-Allowed-Origin header
        if (req.Method.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
        {
            // TODO: Create response and add header
        }

        try
        {
            // TODO 2: Read request body
            var requestBody = await req.ReadAsStringAsync();
            if (string.IsNullOrEmpty(requestBody))
            {
                return req.CreateResponse(HttpStatusCode.BadRequest);
            }

            // TODO 3: Parse JSON - handle both single object and array
            // Hint: Use JsonDocument.Parse()

            // TODO 4: For each event, check eventType:
            // - "Microsoft.EventGrid.SubscriptionValidationEvent" -> return validationResponse
            // - "Microsoft.Storage.BlobCreated" -> log the event details

            // TODO 5: For BlobCreated events, log:
            // - Event ID
            // - Subject (contains blob path)
            // - Blob URL from data.url
            // - Content type, length, API

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
}
