using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace CloudShop.Functions;

public class OrdersApi
{
    private readonly ILogger<OrdersApi> _logger;

    public OrdersApi(ILogger<OrdersApi> logger)
    {
        _logger = logger;
    }

    [Function("GetOrders")]
    public HttpResponseData GetOrders(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "orders")] HttpRequestData req)
    {
        _logger.LogInformation("Orders API: GET /orders");

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "application/json");
        response.WriteString(JsonSerializer.Serialize(new
        {
            message = "Orders API is running",
            info = "Orders are processed via Service Bus (see Exercise 10)"
        }));
        return response;
    }

    [Function("CreateOrder")]
    public async Task<HttpResponseData> CreateOrder(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "orders")] HttpRequestData req)
    {
        _logger.LogInformation("Orders API: POST /orders");

        var body = await req.ReadAsStringAsync();
        var order = JsonSerializer.Deserialize<Order>(body, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (order == null)
        {
            var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
            badRequest.Headers.Add("Content-Type", "application/json");
            badRequest.WriteString(JsonSerializer.Serialize(new { error = "Invalid order data" }));
            return badRequest;
        }

        // Assign order metadata
        order.Id = Guid.NewGuid().ToString();
        order.CreatedAt = DateTime.UtcNow;
        order.Status = "Received";
        order.Source = "API";

        _logger.LogInformation("Order received: {OrderId} from {Customer}, Total: {Total}",
            order.Id, order.Customer, order.Total);

        // In Exercise 10, this order will be sent to Service Bus
        // For now, just acknowledge receipt
        var response = req.CreateResponse(HttpStatusCode.Accepted);
        response.Headers.Add("Content-Type", "application/json");
        response.WriteString(JsonSerializer.Serialize(new
        {
            message = "Order received",
            orderId = order.Id,
            status = order.Status,
            note = "Service Bus integration added in Exercise 10"
        }));
        return response;
    }

    [Function("HealthCheck")]
    public HttpResponseData HealthCheck(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] HttpRequestData req)
    {
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "application/json");
        response.WriteString(JsonSerializer.Serialize(new
        {
            status = "healthy",
            service = "CloudShop Orders API",
            timestamp = DateTime.UtcNow
        }));
        return response;
    }
}
