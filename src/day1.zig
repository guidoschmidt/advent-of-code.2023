const std = @import("std");
const wasm = @import("./wasm.zig");

const Allocator = std.mem.Allocator;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn strToDigit(s: []const u8) u8 {
    const words = [_][]const u8{
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
    };
    for(words, 1..) |word, i| {
        if (std.mem.eql(u8, word, s)) {
            return @intCast(i);
        }
    }
    return 0;
}

fn part1(input: []const u8) anyerror!u32 {
    var result: u32 = 0;

    var it = std.mem.tokenize(u8, input, "\n");
    while(it.next()) |v| {
        var number: u32 = 0;
        var first: u8 = 0;
        var last: u8 = 0;

        for(0..v.len) |x| {
            const digit = std.fmt.charToDigit(v[x], 10) catch continue;
            if (first == 0) {
                first = digit;
                break;
            }
        }

        for(0..v.len) |x| {
            const digit = std.fmt.charToDigit(v[v.len - 1 - x], 10) catch 0;
            if (digit != 0) {
                last = digit;
                break;
            }
        }

        number = 10 * first;
        number += last;

        result += number;
    }

    wasm.logU32(result);
    return result;
}

fn part2(input: []const u8) anyerror!u32 {
    var result: u32 = 0;

    var it = std.mem.tokenize(u8, input, "\n");
    while(it.next()) |v| {
        var number: u32 = 0;
        var first: u8 = 0;
        var last: u8 = 0;

        for(0..v.len) |x| {
            if (v.len >= 3 and x < v.len - 3) {
                const word = v[x..x + 3];
                const digit = strToDigit(word);
                if (digit != 0 and first == 0) {
                    first = digit;
                    break;
                }
            }
            if (v.len >= 4 and x < v.len - 4) {
                const word = v[x..x + 4];
                const digit = strToDigit(word);
                if (digit != 0 and first == 0) {
                    first = digit;
                    break;
                }
            }
            if (v.len >= 5 and x < v.len - 5) {
                const word = v[x..x + 5];
                const digit = strToDigit(word);
                if (digit != 0 and first == 0) {
                    first = digit;
                    break;
                }
            }
            const digit = std.fmt.charToDigit(v[x], 10) catch continue;
            if (first == 0) {
                first = digit;
                break;
            }
        }

        for(0..v.len) |x| {
            var digit = std.fmt.charToDigit(v[v.len - 1 - x], 10) catch 0;
            if (digit != 0) {
                last = digit;
                break;
            }
            const end = v.len - x;
            if (v.len >= 3 and x < v.len - 3) {
                const start = end - 3;
                const word = v[start..end];
                digit = strToDigit(word);
                if (digit != 0) {
                    last = digit;
                    break;
                }
            }
            if (v.len >= 4 and x < v.len - 4) {
                const start = end - 4;
                const word = v[start..end];
                digit = strToDigit(word);
                if (digit != 0) {
                    last = digit;
                    break;
                }
            }
            if (v.len >= 5 and x < v.len - 5) {
                const start = end - 5;
                const word = v[start..end];
                digit = strToDigit(word);
                if (digit != 0) {
                    last = digit;
                    break;
                }
            }
        }

        number = 10 * first;
        number += last;

        result += number;
    }

    wasm.logU32(result);
    return result;
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
        @panic("Could not run part 1!");
    };
}
