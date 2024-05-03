const std = @import("std");
const wasm = @import("./wasm.zig");

const Allocator = std.mem.Allocator;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocator = arena.allocator();


pub fn part1(input: []const u8) anyerror!u32 {
    var it = std.mem.tokenize(u8, input, "\n");
    var result: u32 = 0;

    const max_red = 12;
    const max_green = 13;
    const max_blue = 14;

    game: while (it.next()) |v| {
        if (v.len <= 1) continue;
        wasm.logStr(v.ptr, v.len);
        wasm.logUsize(v.len);
        var line_it = std.mem.split(u8, v, ":");
        const game_id_str = line_it.next().?;
        var id_str_it = std.mem.tokenize(u8, game_id_str, " ");
        _ = id_str_it.next();
        const game_id = try std.fmt.parseInt(u8, id_str_it.next().?, 10);

        const config = line_it.next().?;
        var set_it = std.mem.tokenize(u8, config, ";");
        while(set_it.next()) |set| {
            var cube_it = std.mem.tokenize(u8, set, ",");
            while(cube_it.next()) |cube| {
                var digit_color_it = std.mem.tokenize(u8, cube, " ");
                const digit_str = digit_color_it.next().?;
                const color = digit_color_it.next().?;
                const digit = try std.fmt.parseInt(u16, digit_str, 10);
                if ((std.mem.eql(u8, color, "red") and digit > max_red) or
                    (std.mem.eql(u8, color, "green") and digit > max_green) or
                    (std.mem.eql(u8, color, "blue") and digit > max_blue)) {
                    continue :game;
                }
            }
        }
        result += game_id;
    }

    wasm.logU32(result);
    return result;
}

pub fn part2(input: []const u8) anyerror!u32 {
    var it = std.mem.tokenize(u8, input, "\n");
    var result: u32 = 0;
    var sum_of_powers: u32 = 0;
    // game
    while (it.next()) |v| {
        if (v.len <= 1) continue;
        wasm.logStr(v.ptr, v.len);
        wasm.logUsize(v.len);
        var line_it = std.mem.split(u8, v, ":");
        const game_id_str = line_it.next().?;
        var id_str_it = std.mem.tokenize(u8, game_id_str, " ");
        _ = id_str_it.next();
        const game_id = try std.fmt.parseInt(u8, id_str_it.next().?, 10);

        var lowest_red: u16 = 1;
        var lowest_green: u16 = 1;
        var lowest_blue: u16 = 1;

        const config = line_it.next().?;
        var set_it = std.mem.tokenize(u8, config, ";");
        while(set_it.next()) |set| {
            var cube_it = std.mem.tokenize(u8, set, ",");
            while(cube_it.next()) |cube| {
                var digit_color_it = std.mem.tokenize(u8, cube, " ");
                const digit_str = digit_color_it.next().?;
                const color = digit_color_it.next().?;
                const digit = try std.fmt.parseInt(u16, digit_str, 10);
                // if ((std.mem.eql(u8, color, "red") and digit > max_red) or
                //     (std.mem.eql(u8, color, "green") and digit > max_green) or
                //     (std.mem.eql(u8, color, "blue") and digit > max_blue)) {
                //     std.debug.print("\n→ {d} IMPOSSIBLE due to {s} {d}\n   {s}", .{
                //         game_id, color, digit, config
                //     });
                //     continue :game;
                // }
                if ((std.mem.eql(u8, color, "red") and digit > lowest_red)) {
                    lowest_red = digit;
                }
                if ((std.mem.eql(u8, color, "green") and digit > lowest_green)) {
                    lowest_green = digit;
                }
                if ((std.mem.eql(u8, color, "blue") and digit > lowest_blue)) {
                    lowest_blue = digit;
                }
            }
        }
        result += game_id;
        sum_of_powers += lowest_red * lowest_green * lowest_blue;
    }

    wasm.logU32(sum_of_powers);
    return sum_of_powers;
}

export fn part1_wasm(input: [*:0]u8, input_len: usize) u32 {
    defer arena.deinit();
    var internal_input: [:0]u8 = undefined;
    internal_input.ptr = input;
    internal_input.len = input_len;
    return part1(internal_input) catch {
        @panic("Could not run part 1!");
    };
}

export fn part2_wasm(input: [*:0]u8, input_len: usize) u32 {
    defer arena.deinit();
    var internal_input: [:0]u8 = undefined;
    internal_input.ptr = input;
    internal_input.len = input_len;
    return part2(internal_input) catch {
        @panic("Could not run part 2!");
    };
}
