using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using System.Text.Json;

namespace CloudShopEventHubs;

public class Producer
{
    private readonly EventHubProducerClient _producer;
    private readonly Random _random = new();

    public Producer(string connectionString, string eventHubName)
    {
        _producer = new EventHubProducerClient(connectionString, eventHubName);
    }

    public async Task SendEventsAsync(int count)
    {
        var pages = new[] { "/products/widget-001", "/products/gadget-002", "/cart", "/checkout", "/home" };
        var actions = new[] { "view", "click", "scroll", "purchase", "add_to_cart" };
        var browsers = new[] { "Chrome", "Firefox", "Safari", "Edge" };
        var devices = new[] { "desktop", "mobile", "tablet" };

        using var batch = await _producer.CreateBatchAsync();

        for (int i = 0; i < count; i++)
        {
            var clickEvent = new
            {
                sessionId = Guid.NewGuid().ToString(),
                userId = $"user-{_random.Next(1, 1001)}",
                page = pages[_random.Next(pages.Length)],
                action = actions[_random.Next(actions.Length)],
                timestamp = DateTime.UtcNow.ToString("o"),
                metadata = new
                {
                    browser = browsers[_random.Next(browsers.Length)],
                    device = devices[_random.Next(devices.Length)]
                }
            };

            var eventData = new EventData(JsonSerializer.SerializeToUtf8Bytes(clickEvent));

            if (!batch.TryAdd(eventData))
            {
                // Batch is full, send and create new
                await _producer.SendAsync(batch);
                Console.WriteLine($"Sent batch of events");
                using var newBatch = await _producer.CreateBatchAsync();
                newBatch.TryAdd(eventData);
            }

            if ((i + 1) % 10 == 0)
            {
                Console.WriteLine($"Created {i + 1} events...");
            }
        }

        // Send remaining events
        if (batch.Count > 0)
        {
            await _producer.SendAsync(batch);
            Console.WriteLine("Sent final batch");
        }

        Console.WriteLine($"\nTotal events sent: {count}");
    }

    public async ValueTask DisposeAsync()
    {
        await _producer.DisposeAsync();
    }
}
