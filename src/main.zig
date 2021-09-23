const std = @import("std");
const sim = @import("./simulator.zig");
const io = std.io;
const stdin = io.getStdIn();
const stdout = io.getStdOut().writer();
const stderr = io.getStdErr().writer();

fn parseInputs(filename: []u8, allocator: *std.mem.Allocator) !sim.SimInputs {
    const file = try std.fs.cwd().openFile(
        filename,
        .{ .read = true },
    );
    defer file.close();

    const bytes = try file.reader().readAllAlloc(allocator, 1_000_000);

    var stream = std.json.TokenStream.init(bytes);

    // This is necessary because the json parser traverses the whole
    // struct at compile time, and the default of 1000 is not sufficient.
    @setEvalBranchQuota(10000);
    return try std.json.parse(sim.SimInputs, &stream, .{.allocator = allocator});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var args_it = std.process.args();
    // Skip the executable name
    _ = args_it.skip();

    if (args_it.next(allocator)) |arg| {
        // Parse input
        const inputs = parseInputs(try arg, allocator) catch |err| {
            try stderr.print("There was an error while parsing " ++
                "the JSON file: {}\n", .{err});
            return;
        };

        // Run simulation
        const output = try sim.simulate(inputs, allocator);

        // Print output
        try stdout.print("time, temperature\n", .{});

        for (output) |time_temp| {
            try stdout.print("{d:.6}, {d:.6}\n",
                .{time_temp.time, time_temp.temp});
        }
    } else {
        try stderr.print("Usage: ./simulator config.json\n", .{});
    }
}
