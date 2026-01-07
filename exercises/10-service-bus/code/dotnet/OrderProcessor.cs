using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace CloudShop.Functions;

/// <summary>
/// Processes orders from the Service Bus queue.
/// This is the final step in the order processing pipeline.
/// </summary>
public class OrderProcessor
{
    private readonly ILogger<OrderProcessor> _logger;

    public OrderProcessor(ILogger<OrderProcessor> logger)
    {
        _logger = logger;
    }

    [Function("ProcessOrder")]
    public async Task Run(
        [ServiceBusTrigger("orders", Connection = "ServiceBusConnection")]
        ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        _logger.LogInformation("=== PROCESSING ORDER ===");
        _logger.LogInformation("Message ID: {MessageId}", message.MessageId);
        _logger.LogInformation("Delivery Count: {DeliveryCount}", message.DeliveryCount);

        try
        {
            var orderMessage = JsonSerializer.Deserialize<OrderMessage>(message.Body.ToString());

            if (orderMessage == null)
            {
                _logger.LogError("Failed to deserialize order message");
                await messageActions.DeadLetterMessageAsync(message,
                    deadLetterReason: "DeserializationFailed",
                    deadLetterErrorDescription: "Could not deserialize order message");
                return;
            }

            _logger.LogInformation("Order ID: {OrderId}", orderMessage.OrderId);
            _logger.LogInformation("Source: {Source}", orderMessage.Source);
            _logger.LogInformation("Customer: {Customer}", orderMessage.Order?.Customer);
            _logger.LogInformation("Total: {Total:C}", orderMessage.Order?.Total);

            // Simulate processing
            await Task.Delay(500);

            // Demo: Orders over $10000 are flagged for review (sent to dead-letter)
            if (orderMessage.Order?.Total > 10000)
            {
                _logger.LogWarning("Order {OrderId} exceeds $10,000 - flagging for review",
                    orderMessage.OrderId);
                await messageActions.DeadLetterMessageAsync(message,
                    deadLetterReason: "ManualReviewRequired",
                    deadLetterErrorDescription: $"Order total ${orderMessage.Order.Total} exceeds limit");
                return;
            }

            _logger.LogInformation("Order {OrderId} processed successfully!", orderMessage.OrderId);
            await messageActions.CompleteMessageAsync(message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing order");

            // After max delivery attempts, message goes to dead-letter automatically
            if (message.DeliveryCount >= 3)
            {
                await messageActions.DeadLetterMessageAsync(message,
                    deadLetterReason: "ProcessingFailed",
                    deadLetterErrorDescription: ex.Message);
            }
            else
            {
                // Abandon to retry
                await messageActions.AbandonMessageAsync(message);
            }
        }
    }
}
