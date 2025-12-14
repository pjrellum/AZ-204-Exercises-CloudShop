using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace CloudShopOrders;

public class Orders
{
    private readonly ILogger<Orders> _logger;

    // TODO: Add a static list to store orders in memory
    // Hint: private static readonly List<Order> _orders = new();

    public Orders(ILogger<Orders> logger)
    {
        _logger = logger;
    }

    // TODO: Implement GetOrders function
    // Requirements:
    // - Function name: "GetOrders"
    // - HTTP trigger: GET method
    // - Route: "orders"
    // - Authorization level: Anonymous (APIM handles auth)
    // - Return: JSON list of orders
    //
    // Hint: Use [Function("GetOrders")] and [HttpTrigger(...)] attributes


    // TODO: Implement CreateOrder function
    // Requirements:
    // - Function name: "CreateOrder"
    // - HTTP trigger: POST method
    // - Route: "orders"
    // - Read JSON body and deserialize to Order
    // - Set Id (new GUID), CreatedAt (now), Status ("Pending")
    // - Add to orders list
    // - Return: Created order as JSON with 201 status
    //
    // Hint: Use async Task<HttpResponseData> and req.ReadAsStringAsync()

}

// TODO: Define Order class with properties:
// - Id (string)
// - Customer (string)
// - Items (List<OrderItem>)
// - Total (decimal)
// - Status (string)
// - CreatedAt (DateTime)

// TODO: Define OrderItem class with properties:
// - Sku (string)
// - Quantity (int)
// - Price (decimal)
