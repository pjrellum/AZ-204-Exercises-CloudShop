using CloudShopEventHubs;

// Parse command line arguments
var args = Environment.GetCommandLineArgs();
var mode = args.Length > 1 ? args[1] : "producer";
var connection = GetArg(args, "--connection") ?? Environment.GetEnvironmentVariable("EVENTHUB_CONNECTION_STRING") ?? "";
var hubName = GetArg(args, "--hub") ?? "clickstream";
var count = int.Parse(GetArg(args, "--count") ?? "100");
var storageConnection = GetArg(args, "--storage") ?? Environment.GetEnvironmentVariable("STORAGE_CONNECTION_STRING") ?? "";

if (string.IsNullOrEmpty(connection))
{
    Console.WriteLine("Error: Provide --connection or set EVENTHUB_CONNECTION_STRING");
    return;
}

if (mode == "producer" || mode == "send")
{
    Console.WriteLine($"=== Event Hubs Producer ===");
    Console.WriteLine($"Hub: {hubName}");
    Console.WriteLine($"Count: {count}");
    Console.WriteLine();

    var producer = new Producer(connection, hubName);
    await producer.SendEventsAsync(count);
}
else if (mode == "consumer" || mode == "receive")
{
    if (string.IsNullOrEmpty(storageConnection))
    {
        Console.WriteLine("Error: Consumer requires --storage or STORAGE_CONNECTION_STRING");
        return;
    }

    Console.WriteLine($"=== Event Hubs Consumer ===");
    Console.WriteLine($"Hub: {hubName}");
    Console.WriteLine();

    var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (_, e) =>
    {
        e.Cancel = true;
        cts.Cancel();
    };

    var consumer = new Consumer(connection, hubName, storageConnection, "checkpoints");
    await consumer.StartAsync(cts.Token);
}
else
{
    Console.WriteLine("Usage:");
    Console.WriteLine("  dotnet run producer --connection <conn> --hub <name> --count <n>");
    Console.WriteLine("  dotnet run consumer --connection <conn> --hub <name> --storage <conn>");
}

string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    return index >= 0 && index < args.Length - 1 ? args[index + 1] : null;
}
