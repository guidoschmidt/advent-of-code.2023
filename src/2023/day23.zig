const std = @import("std");
const aoc = @import("aoc");

const Allocator = std.mem.Allocator;

const Route = struct {
    map: [][]u8 = undefined,
    steps: u32 = 0,
    pos_x: i16,
    pos_y: i16,
    prev_pos_x: i16,
    prev_pos_y: i16,
    route_id: u32,

    pub fn findNext_part1(self: *Route, gpa: Allocator, map: *[][]u8) !std.ArrayList(Route) {
        var split_routes = std.ArrayList(Route).init(gpa);
        // map.*[@intCast(self.pos_y)][@intCast(self.pos_x)] = 'O';
        const x_o = [4]i2{  0,  0, -1,  1 };
        const y_o = [4]i2{ -1,  1,  0,  0 };
        for(0..4) |i| {
            const ox = x_o[i];
            const oy = y_o[i];
            const _y = @max(self.pos_y + @as(i16, @intCast(oy)), 0);
            const _x = @max(self.pos_x + @as(i16, @intCast(ox)), 0);
            if (_y == self.pos_y and _x == self.pos_x) continue;
            if (_y == self.prev_pos_y and _x == self.prev_pos_x) continue;
            const map_val = map.*[@intCast(_y)][@intCast(_x)];
            switch (map_val) {
                '.' => {
                    try split_routes.append(Route {
                        .steps = self.steps + 1,
                        .pos_x = _x,
                        .pos_y = _y,
                        .prev_pos_x = self.pos_x,
                        .prev_pos_y = self.pos_y,
                        .route_id = 0,
                    });
                },
                'v' => {
                    if (ox == 1) {
                        try split_routes.append(Route {
                            .steps = self.steps + 1,
                            .pos_x = _x,
                            .pos_y = _y,
                            .prev_pos_x = self.pos_x,
                            .prev_pos_y = self.pos_y,
                            .route_id = 0,
                        });
                    }
                },
                '>' => {
                    if (oy == 1) {
                        try split_routes.append(Route {
                            .steps = self.steps + 1,
                            .pos_x = _x,
                            .pos_y = _y,
                            .prev_pos_x = self.pos_x,
                            .prev_pos_y = self.pos_y,
                            .route_id = 0,
                        });
                    }
                },
                '<' => {
                    if (oy == -1) {
                        try split_routes.append(Route {
                            .steps = self.steps + 1,
                            .pos_x = _x,
                            .pos_y = _y,
                            .prev_pos_x = self.pos_x,
                            .prev_pos_y = self.pos_y,
                            .route_id = 0,
                        });
                    }
                },
                '^' => {
                    if (ox == -1) {
                        try split_routes.append(Route {
                            .steps = self.steps + 1,
                            .pos_x = _x,
                            .pos_y = _y,
                            .prev_pos_x = self.pos_x,
                            .prev_pos_y = self.pos_y,
                            .route_id = 0,
                        });
                    }
                },
                else => {}
            }
        }
        return split_routes;
    }

    pub fn findNext_part2(self: *Route, gpa: Allocator, map: *[][]u8, viz_map: *[][]u8) !std.ArrayList(Route) {
        var split_routes = std.ArrayList(Route).init(gpa);
        self.map[@intCast(self.pos_y)][@intCast(self.pos_x)] = 'X';
        viz_map.*[@intCast(self.pos_y)][@intCast(self.pos_x)] = 'X';
        printCharMap(&self.map);
        aoc.blockAskForNext();
        const x_o = [4]i2{  0,  0, -1,  1 };
        const y_o = [4]i2{ -1,  1,  0,  0 };
        var found_routes: usize = 0;
        for(0..4) |i| {
            const ox = x_o[i];
            const oy = y_o[i];
            const _y = @max(self.pos_y + @as(i16, @intCast(oy)), 0);
            const _x = @max(self.pos_x + @as(i16, @intCast(ox)), 0);
            if (_y == self.pos_y and _x == self.pos_x) continue;
            if (_y == self.prev_pos_y and _x == self.prev_pos_x) continue;
            const map_val = map.*[@intCast(_y)][@intCast(_x)];
            switch (map_val) {
                '.', 'v', '^', '<', '>' => {
                    if (self.map[@intCast(_y)][@intCast(_x)] == 'X') continue;
                    const map_dup = try gpa.dupe([]u8, self.map);
                    for (0..map_dup.len) |x| {
                        for (0..map_dup[x].len) |y| {
                            map_dup[x][y] = self.map[x][y];
                        }
                    }
                    try split_routes.append(Route {
                        .steps = self.steps + 1,
                        .pos_x = _x,
                        .pos_y = _y,
                        .prev_pos_x = self.pos_x,
                        .prev_pos_y = self.pos_y,
                        .route_id = self.route_id + @as(u32, @intCast(found_routes)),
                        .map = map_dup,
                    });
                    found_routes += 1;
                },
                else => {}
            }
        }
        return split_routes;
    }
};

fn printCharMap(map: *[][]u8) void {
    std.debug.print("\n", .{});
    for (0..map.len) |x| {
        const row = map.*[x];
        std.debug.print("\n", .{});
        for(0..row.len) |y| {
            const v = map.*[y][x];
            switch(v) {
                'X' => std.debug.print("{c}", .{ v }),
                else => std.debug.print("{c}", .{ v }),
            }
        }
    }
}

fn printMap(map: *[][]u16) void {
    std.debug.print("\n", .{});
    for (0..map.len) |x| {
        const row = map.*[x];
        std.debug.print("\n", .{});
        for(0..row.len) |y| {
            const v = map.*[y][x];
            if (v > 1) {
                std.debug.print("{s}{d}{s}", .{ aoc.red, v , aoc.clear });
            }
            else{
                std.debug.print("{d}", .{ v });
            }
        }
    }
}

fn part1(gpa: Allocator, input: []const u8) anyerror!void {
    var row_it = std.mem.tokenize(u8, input, "\n");

    const width = row_it.peek().?.len;
    var height: usize = 0;
    while(row_it.next()) |_| { height += 1; }

    std.debug.print("\n{d} x {d}", .{ width, height });

    const cleaned_input = try std.mem.replaceOwned(u8, gpa, input, "\n", "");

    var map = try gpa.alloc([]u8, width);
    var viz_map = try gpa.alloc([]u8, width);
    var start_x: usize = 0;
    var goal_x: usize = 0;
    for(0..map.len) |x| {
        map[x] = try gpa.alloc(u8, height);
        viz_map[x] = try gpa.alloc(u8, height);
        for(0..height) |y| {
            const map_val = cleaned_input[y * height + x];
            // Find start
            if (y == 0 and map_val == '.') {
                std.debug.print("{c}", .{ cleaned_input[y * height + x]});
                start_x = x;
            }
            // Find end
            if (y == height - 1 and map_val == '.') {
                goal_x = x; 
            }
            map[x][y] = map_val;
            viz_map[x][y] = map_val;
        }
    }

    std.debug.print("\nStart [{d} x {d}]", .{ start_x, 0 });
    std.debug.print("\nGoal [{d} x {d}]", .{ goal_x, 0 });

    var routes = std.ArrayList(Route).init(gpa);
    try routes.append(Route {
        .pos_x = 0,
        .pos_y = @intCast(start_x),
        .prev_pos_x = 0,
        .prev_pos_y = 0,
        .steps = 0,
        .route_id = 0,
    });
    std.debug.print("\nGoal [{d} x {d}]", .{ goal_x, height });
    var finished_routes = std.ArrayList(Route).init(gpa);
    while (routes.items.len > 0) {
        var next_route = routes.pop();
        viz_map[@intCast(next_route.pos_y)][@intCast(next_route.pos_x)] = 'X';
        // printMap(&viz_map);
        // aoc.blockAskForNext();
        if (next_route.pos_x > goal_x) {
            try finished_routes.append(next_route);
            continue;
        }
        const split_routes = try next_route.findNext_part1(gpa, &map);
        for (split_routes.items) |route| {
            try routes.append(route);
        }
    }

    std.debug.print("\nFound {d} routes", .{ finished_routes.items.len });

    var longest_route: u32 = 0;
    for(finished_routes.items) |finished_route| {
        if (finished_route.steps > longest_route)
            longest_route = finished_route.steps;
    }
    std.debug.print("\nSteps: {d}", .{ longest_route });
}

fn part2(gpa: Allocator, input: []const u8) anyerror!void {
    var row_it = std.mem.tokenize(u8, input, "\n");

    const width = row_it.peek().?.len;
    var height: usize = 0;
    while(row_it.next()) |_| { height += 1; }

    std.debug.print("\n{d} x {d}", .{ width, height });

    const cleaned_input = try std.mem.replaceOwned(u8, gpa, input, "\n", "");

    var map = try gpa.alloc([]u8, width);
    var viz_map = try gpa.alloc([]u8, width);
    var history_map = try gpa.alloc([]u16, width);
    var start_x: usize = 0;
    var goal_x: usize = 0;
    for(0..map.len) |x| {
        map[x] = try gpa.alloc(u8, height);
        viz_map[x] = try gpa.alloc(u8, height);
        history_map[x] = try gpa.alloc(u16, height);
        for(0..height) |y| {
            const map_val = cleaned_input[y * height + x];
            // Find start
            if (y == 0 and map_val == '.') {
                std.debug.print("{c}", .{ cleaned_input[y * height + x]});
                start_x = x;
            }
            // Find end
            if (y == height - 1 and map_val == '.') {
                goal_x = x; 
            }
            map[x][y] = map_val;
            viz_map[x][y] = map_val;
            history_map[x][y] = 0;
        }
    }

    std.debug.print("\nStart [{d} x {d}]", .{ start_x, 0 });
    std.debug.print("\nGoal [{d} x {d}]", .{ goal_x, 0 });

    var routes = std.ArrayList(Route).init(gpa);
    try routes.append(Route {
        .pos_x = 0,
        .pos_y = @intCast(start_x),
        .prev_pos_x = 0,
        .prev_pos_y = 0,
        .steps = 0,
        .route_id = 1,
        .map = try gpa.dupe([]u8, viz_map),
    });
    std.debug.print("\nGoal [{d} x {d}]", .{ goal_x, height });
    var finished_routes = std.ArrayList(Route).init(gpa);
    while (routes.items.len > 0) {
        var next_route = routes.pop();
        viz_map[@intCast(next_route.pos_y)][@intCast(next_route.pos_x)] = 'X';
        // printMap(&history_map);
        // printCharMap(&viz_map);
        // aoc.blockAskForNext();
        if (next_route.pos_x > goal_x) {
            try finished_routes.append(next_route);
            continue;
        }
        const split_routes = try next_route.findNext_part2(gpa, &map, &viz_map);
        for (split_routes.items) |route| {
            try routes.append(route);
        }
    }

    // printMap(&history_map);
    printCharMap(&viz_map);

    std.debug.print("\nFound {d} routes", .{ finished_routes.items.len });

    var longest_route: u32 = 0;
    for(finished_routes.items) |finished_route| {
        if (finished_route.steps > longest_route)
            longest_route = finished_route.steps;
    }
    std.debug.print("\nSteps: {d}", .{ longest_route });
}

pub fn main() !void {
    var gpa_generator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_generator.allocator();

    try aoc.runPart(gpa, 2023, 23, .EXAMPLE, part2);
    try aoc.runPart(gpa, 2023, 23, .EXAMPLE, part2);
}
