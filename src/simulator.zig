const std = @import("std");

pub const DynamicInput = struct {
    time: f32,
    value: f32,
};

pub const SimInputs = struct {
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
    ending_time: f32,
};

pub const TimeTemp = struct {
    time: f32,
    temp: f32,
};

pub fn simulate(inputs: SimInputs, allocator: *std.mem.Allocator) ![]TimeTemp {
    var output = std.ArrayList(TimeTemp).init(allocator);

    try output.append(TimeTemp{ .time = 0.0, .temp = inputs.starting_temp });

    // No need for deinit() because the caller now owns this
    return output.toOwnedSlice();
}
