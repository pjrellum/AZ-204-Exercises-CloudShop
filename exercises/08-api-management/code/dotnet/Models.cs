namespace CloudShop.Functions;

public class Order
{
    public string? Id { get; set; }
    public string? Customer { get; set; }
    public List<OrderItem>? Items { get; set; }
    public decimal Total { get; set; }
    public string? Status { get; set; }
    public string? Source { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class OrderItem
{
    public string? Sku { get; set; }
    public string? Name { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}
