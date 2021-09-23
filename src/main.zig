const std = @import("std");
const io = std.io;
const stdin = io.getStdIn();
const stdout = io.getStdOut().writer();
const stderr = io.getStdErr().writer();

const DynamicInput = struct {
    time: f32,
    value: f32,
};

const SimInputs = struct {
    time_slice_length: f32,
    starting_temp: f32,
    set_point_temp: f32,
    cold_water_temp: f32,
    solar_irradiance: []DynamicInput,
    stc_panel_area: f32,
    stc_panel_count: u32,
    stc_efficiency: f32,
    specific_heat: f32,
    aux_heat_power: []DynamicInput,
    aux_efficiency: f32,
    hot_water_demand: []DynamicInput,
    tank_volume: u32,
    tank_loss_coefficient: f32,
};

fn parseConfig(filename: []u8, allocator: *std.mem.Allocator) !SimInputs {
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
    return try std.json.parse(SimInputs, &stream, .{.allocator = allocator});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var args_it = std.process.args();
    // Skip the executable name
    _ = args_it.skip();
    if (args_it.next(allocator)) |arg| {
        const config = parseConfig(try arg, allocator) catch |err| {
            try stderr.print("There was an error while parsing" ++
                "the JSON file: {}\n", .{err});
            return;
        };

        std.debug.print("Siminputs: {}\n", .{config});
    } else {
        try stderr.print("Usage: ./simulator config.json\n", .{});
    }
}
