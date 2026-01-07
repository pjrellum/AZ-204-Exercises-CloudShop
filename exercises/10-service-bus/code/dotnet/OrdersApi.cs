using System.Net;
using System.Text.Json;
using Azure.Messaging.ServiceBus;
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
            info = "Orders are sent to Service Bus for processing"
        }));
        return response;
    }

    [Function("CreateOrder")]
    [ServiceBusOutput("orders", Connection = "ServiceBusConnection")]
    public async Task<OrderMessage> CreateOrder(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "orders")] HttpRequestData req,
        FunctionContext context)
    {
        var logger = context.GetLogger<OrdersApi>();
        logger.LogInformation("Orders API: POST /orders");

        var body = await req.ReadAsStringAsync();
        var order = JsonSerializer.Deserialize<Order>(body, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (order == null)
        {
            throw new ArgumentException("Invalid order data");
        }

        // Assign order metadata
        order.Id = Guid.NewGuid().ToString();
        order.CreatedAt = DateTime.UtcNow;
        order.Status = "Queued";
        order.Source = "API";

        logger.LogInformation("Order queued: {OrderId} from {Customer}, Total: {Total}",
            order.Id, order.Customer, order.Total);

        // Return the order message - it will be sent to Service Bus
        return new OrderMessage
        {
            OrderId = order.Id,
            Order = order,
            Source = "API",
            QueuedAt = DateTime.UtcNow
        };
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
