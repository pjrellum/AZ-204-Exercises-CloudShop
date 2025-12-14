using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using System.Text.Json;

namespace CloudShopEventHubs;

public class Consumer
{
    private readonly EventProcessorClient _processor;

    public Consumer(string eventHubConnection, string eventHubName, string storageConnection, string containerName)
    {
        var storageClient = new BlobContainerClient(storageConnection, containerName);
        _processor = new EventProcessorClient(
            storageClient,
            EventHubConsumerClient.DefaultConsumerGroupName,
            eventHubConnection,
            eventHubName);

        _processor.ProcessEventAsync += ProcessEventAsync;
        _processor.ProcessErrorAsync += ProcessErrorAsync;
        _processor.PartitionInitializingAsync += PartitionInitializingAsync;
        _processor.PartitionClosingAsync += PartitionClosingAsync;
    }

    public async Task StartAsync(CancellationToken cancellationToken = default)
    {
        Console.WriteLine("Starting consumer...");
        Console.WriteLine("Press Ctrl+C to stop\n");

        await _processor.StartProcessingAsync(cancellationToken);

        // Keep running until cancelled
        try
        {
            await Task.Delay(Timeout.Infinite, cancellationToken);
        }
        catch (TaskCanceledException)
        {
            // Expected when cancellation is requested
        }

        await _processor.StopProcessingAsync();
        Console.WriteLine("\nConsumer stopped.");
    }

    private Task ProcessEventAsync(ProcessEventArgs args)
    {
        try
        {
            var body = args.Data.EventBody.ToString();
            var data = JsonSerializer.Deserialize<JsonElement>(body);

            Console.WriteLine($"\n[Partition {args.Partition.PartitionId}] Event received:");
            Console.WriteLine($"  Session: {GetJsonValue(data, "sessionId")?[..8]}...");
            Console.WriteLine($"  User: {GetJsonValue(data, "userId")}");
            Console.WriteLine($"  Page: {GetJsonValue(data, "page")}");
            Console.WriteLine($"  Action: {GetJsonValue(data, "action")}");
            Console.WriteLine($"  Timestamp: {GetJsonValue(data, "timestamp")}");
        }
        catch (JsonException)
        {
            Console.WriteLine($"[Partition {args.Partition.PartitionId}] Raw: {args.Data.EventBody.ToString()[..100]}...");
        }

        // Update checkpoint
        return args.UpdateCheckpointAsync();
    }

    private Task ProcessErrorAsync(ProcessErrorEventArgs args)
    {
        Console.WriteLine($"[Partition {args.PartitionId}] Error: {args.Exception.Message}");
        return Task.CompletedTask;
    }

    private Task PartitionInitializingAsync(PartitionInitializingEventArgs args)
    {
        Console.WriteLine($"Starting to receive from partition {args.PartitionId}");
        return Task.CompletedTask;
    }

    private Task PartitionClosingAsync(PartitionClosingEventArgs args)
    {
        Console.WriteLine($"Stopped receiving from partition {args.PartitionId}. Reason: {args.Reason}");
        return Task.CompletedTask;
    }

    private string? GetJsonValue(JsonElement element, string propertyName)
    {
        return element.TryGetProperty(propertyName, out var prop) ? prop.GetString() : null;
    }
}
