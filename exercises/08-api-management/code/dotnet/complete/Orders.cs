using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace CloudShopOrders;

public class Orders
{
    private readonly ILogger<Orders> _logger;
    private static readonly List<Order> _orders = new();

    public Orders(ILogger<Orders> logger)
    {
        _logger = logger;
    }

    [Function("GetOrders")]
    public HttpResponseData GetOrders(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "orders")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all orders. Count: {Count}", _orders.Count);

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "application/json");
        response.WriteString(JsonSerializer.Serialize(new
        {
            message = "Orders API is running",
            count = _orders.Count,
            orders = _orders
        }));
        return response;
    }

    [Function("CreateOrder")]
    public async Task<HttpResponseData> CreateOrder(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "orders")] HttpRequestData req)
    {
        _logger.LogInformation("Creating new order");

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

        order.Id = Guid.NewGuid().ToString();
        order.CreatedAt = DateTime.UtcNow;
        order.Status = "Pending";
        _orders.Add(order);

        _logger.LogInformation("Order created: {OrderId}", order.Id);

        var response = req.CreateResponse(HttpStatusCode.Created);
        response.Headers.Add("Content-Type", "application/json");
        response.WriteString(JsonSerializer.Serialize(order));
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

public class Order
{
    public string? Id { get; set; }
    public string? Customer { get; set; }
    public List<OrderItem>? Items { get; set; }
    public decimal Total { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class OrderItem
{
    public string? Sku { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}
