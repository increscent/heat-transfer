const std = @import("std");
const expect = std.testing.expect;

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
    end_time: f32,
};

pub const TimeTemp = struct {
    time: f32,
    temp: f32,
};

// This struct keeps track of state associated with the
// dynamic input lists
const Slicer = struct {
    const Self = @This();

    cur_time: f32,
    cur_val: f32,
    index: u32,
    arr: []DynamicInput,
    time_slice: f32,

    pub fn init(arr: []DynamicInput, time_slice: f32) Self {
        return Self{
            .cur_time = 0,
            .cur_val = arr[0].value,
            .index = 1,
            .arr = arr,
            .time_slice = time_slice,
        };
    }

    // This function returns the aggregate of 'value x time'
    // through the whole time slice. There may be multiple
    // values that span a single time slice, or one value may
    // span the whole slice.
    pub fn getNextSlice(self: *Slicer) f32 {
        var total: f32 = 0;
        var prev_time = self.cur_time;
        var end_time = self.cur_time + self.time_slice;

        while (self.arr.len > self.index and
            self.arr[self.index].time <= end_time) : (self.index += 1) {

            // Advance the current time
            self.cur_time = self.arr[self.index].time;
            // Add the value up to the current time
            total += (self.cur_time - prev_time) * self.cur_val;

            // Advance the value and update prev_time
            self.cur_val = self.arr[self.index].value;
            prev_time = self.cur_time;
        }

        if (self.cur_time < end_time) {
            total += (end_time - self.cur_time) * self.cur_val;
            self.cur_time = end_time;
        }

        return total;
    }
};

fn calcTemp(
    inputs: SimInputs,
    prev_temp: f32,
    irradiance_slicer: *Slicer,
    power_slicer: *Slicer,
    demand_slicer: *Slicer
) f32 {
    const loss_percent = inputs.tank_loss_coefficient *
        inputs.time_slice_length;
    const p1 = (1 - loss_percent) * prev_temp;

    // The 'dt' value is included in the slicer calculation
    const qs = irradiance_slicer.getNextSlice() * inputs.stc_efficiency *
        inputs.stc_panel_area * @intToFloat(f32, inputs.stc_panel_count);

    const qh = inputs.aux_efficiency * power_slicer.getNextSlice();

    const p2 = (qs + qh) / (inputs.specific_heat *
        @intToFloat(f32, inputs.tank_volume));

    const delta_temp = inputs.set_point_temp - inputs.cold_water_temp;

    const demand = demand_slicer.getNextSlice();

    const p3 = (delta_temp * demand) / @intToFloat(f32, inputs.tank_volume);

    return p1 + p2 - p3;
}

fn inRange(num: f32, low: f32, high: f32) bool {
    return num >= low and num <= high;
}

pub fn simulate(inputs: SimInputs, allocator: *std.mem.Allocator) ![]TimeTemp {
    // Check inputs
    try expect(inputs.set_point_temp >= inputs.cold_water_temp);
    try expect(inputs.end_time >= inputs.time_slice_length);
    try expect(inRange(inputs.stc_efficiency, 0, 1));
    try expect(inRange(inputs.aux_efficiency, 0, 1));
    try expect(inRange(inputs.tank_loss_coefficient, 0, 1));
    try expect(inputs.time_slice_length > 0);
    try expect(inputs.solar_irradiance.len > 0);
    try expect(inputs.solar_irradiance[0].time == 0.0);
    try expect(inputs.aux_heat_power.len > 0);
    try expect(inputs.aux_heat_power[0].time == 0.0);
    try expect(inputs.hot_water_demand.len > 0);
    try expect(inputs.hot_water_demand[0].time == 0.0);

    var output = std.ArrayList(TimeTemp).init(allocator);

    // The starting time is always 0
    try output.append(TimeTemp{ .time = 0.0, .temp = inputs.starting_temp });

    var irradiance_slicer = Slicer.init(inputs.solar_irradiance,
        inputs.time_slice_length);
    var power_slicer = Slicer.init(inputs.aux_heat_power,
        inputs.time_slice_length);
    var demand_slicer = Slicer.init(inputs.hot_water_demand,
        inputs.time_slice_length);

    var cur_time: f32 = inputs.time_slice_length;
    var prev_temp: f32 = inputs.starting_temp;

    // TODO: Because of inaccuracies in floating point arithmetic,
    // the 'cur_time' will be slightly over 'end_time' when they
    // should be equal.
    while (cur_time <= inputs.end_time) :
        (cur_time += inputs.time_slice_length) {

        const temp = calcTemp(inputs, prev_temp, &irradiance_slicer,
            &power_slicer, &demand_slicer);

        try output.append(TimeTemp{
            .time = cur_time,
            .temp = temp,
        });

        prev_temp = temp;
    }

    // No need for deinit() because the caller now owns this
    return output.toOwnedSlice();
}

// Tests

var test_irradiance = [_]DynamicInput{
    DynamicInput{ .time = 0, .value = 1.361 }
};

var test_power = [_]DynamicInput{
    DynamicInput{ .time = 0, .value = 0 }
};

var test_demand = [_]DynamicInput{
    DynamicInput{ .time = 0, .value = 500 }
};

const test_inputs = SimInputs{
    .time_slice_length = 0.1,
    .starting_temp = 60,
    .set_point_temp = 60,
    .cold_water_temp = 10,
    .solar_irradiance = test_irradiance[0..],
    .stc_panel_area = 3,
    .stc_panel_count = 100,
    .stc_efficiency = 0.5,
    .specific_heat = 0.0012,
    .aux_heat_power = test_power[0..],
    .aux_efficiency = 0.75,
    .hot_water_demand = test_demand[0..],
    .tank_volume = 10000,
    .tank_loss_coefficient = 0.001,
    .end_time = 1,
};

const test_allocator = std.testing.allocator;

test "basic inputs" {
    var inputs = test_inputs;
    const output = try simulate(inputs, test_allocator);
    defer test_allocator.free(output);

    try expect(output[0].temp == 60.0);
    try expect(output[1].temp == 61.445248);
    try expect(output[9].temp == 73.002037);
}

test "smaller interval than time slice" {
    var inputs = test_inputs;
    var demand = [_]DynamicInput{
        DynamicInput{ .time = 0, .value = 100 },
        DynamicInput{ .time = 0.025, .value = 200 },
        DynamicInput{ .time = 0.05, .value = 500 },
        DynamicInput{ .time = 0.10, .value = 1000 },
    };
    inputs.hot_water_demand = demand[0..];
    const output = try simulate(inputs, test_allocator);
    defer test_allocator.free(output);

    try expect(output[0].temp == 60.0);
    try expect(output[1].temp == 61.532749);
    try expect(output[9].temp == 71.090156);
}

test "different irradiance values" {
    var inputs = test_inputs;
    var irradiance = [_]DynamicInput{
        DynamicInput{ .time = 0.0, .value = 0.500 },
        DynamicInput{ .time = 0.1, .value = 0.635 },
        DynamicInput{ .time = 0.2, .value = 0.723 },
        DynamicInput{ .time = 0.3, .value = 0.811 },
        DynamicInput{ .time = 0.4, .value = 0.976 },
        DynamicInput{ .time = 0.5, .value = 1.034 },
        DynamicInput{ .time = 0.6, .value = 0.976 },
        DynamicInput{ .time = 0.7, .value = 0.811 },
        DynamicInput{ .time = 0.2, .value = 0.723 },
        DynamicInput{ .time = 0.1, .value = 0.635 },
    };
    inputs.solar_irradiance = irradiance[0..];
    const output = try simulate(inputs, test_allocator);
    defer test_allocator.free(output);

    try expect(output[0].temp == 60.0);
    try expect(output[1].temp == 60.368999);
    try expect(output[3].temp == 61.554371);
    try expect(output[5].temp == 63.275730);
    try expect(output[7].temp == 64.065475);
    try expect(output[9].temp == 65.140099);
}

test "using the auxiliary water heater" {
    var inputs = test_inputs;
    var power = [_]DynamicInput{
        DynamicInput{ .time = 0.0, .value = 100 },
    };
    inputs.aux_heat_power = power[0..];
    const output = try simulate(inputs, test_allocator);
    defer test_allocator.free(output);

    try expect(output[0].temp == 60.0);
    try expect(output[1].temp == 62.070248);
    try expect(output[5].temp == 70.349167);
    try expect(output[9].temp == 78.624779);
}

test "smaller tank" {
    var inputs = test_inputs;
    inputs.tank_volume = 5000;
    const output = try simulate(inputs, test_allocator);
    defer test_allocator.free(output);

    try expect(output[0].temp == 60.0);
    try expect(output[1].temp == 62.896500);
    try expect(output[6].temp == 77.374649);
    try expect(output[9].temp == 86.058060);
}
