const std = @import("std");
const aoc = @import("aoc");

const Allocator = std.mem.Allocator;

fn part1(allocator: Allocator, input: []const u8) anyerror!void {
    var cards_it = std.mem.tokenize(u8, input, "\n");

    var total_points: u32 = 0;

    while(cards_it.next()) |card| {
        var card_it = std.mem.split(u8, card, ":");
        const card_str = card_it.next();
        var num_list_it = std.mem.split(u8, card_it.next().?, "|");
        var winning_num_list_it = std.mem.tokenize(u8, num_list_it.next().?, " ");
        var player_num_list_it = std.mem.tokenize(u8, num_list_it.next().?, " ");
        std.debug.print("\n- {s} ---\n", .{ card_str.? });

        var winning_numbers = std.ArrayList(u32).init(allocator);
        var player_numbers = std.ArrayList(u32).init(allocator);

        while(winning_num_list_it.next()) |winning_number_str| {
            const winning_number = try std.fmt.parseInt(u32, winning_number_str, 10);
            std.debug.print("{d}, ", .{ winning_number });
            try winning_numbers.append(winning_number);
        }
        while(player_num_list_it.next()) |player_number_str| {
            const player_number = try std.fmt.parseInt(u32, player_number_str, 10);
            std.debug.print("{d}, ", .{ player_number });
            try player_numbers.append(player_number);
        }

        var points: u32 = 0;

        for (player_numbers.items) |pn| {
            for (winning_numbers.items) |wn| {
                if (pn == wn) {
                    if (points == 0) {
                        points = 1;
                    }
                    else {
                        points *= 2;
                    }
                }
            }
        }
        total_points += points;
    }

    std.debug.print("\nTotal Points: {d}", .{ total_points });
}

fn winning_card_count(allocator: Allocator, card: []const u8) !u32 {
    var card_it = std.mem.split(u8, card, ":");
    _ = card_it.next();
    var num_list_it = std.mem.split(u8, card_it.next().?, "|");
    var winning_num_list_it = std.mem.tokenize(u8, num_list_it.next().?, " ");
    var player_num_list_it = std.mem.tokenize(u8, num_list_it.next().?, " ");

    var winning_numbers = std.ArrayList(u32).init(allocator);
    var player_numbers = std.ArrayList(u32).init(allocator);
    defer winning_numbers.deinit();
    defer player_numbers.deinit();

    while(winning_num_list_it.next()) |winning_number_str| {
        const winning_number = try std.fmt.parseInt(u32, winning_number_str, 10);
        try winning_numbers.append(winning_number);
        while(player_num_list_it.next()) |player_number_str| {
            const player_number = try std.fmt.parseInt(u32, player_number_str, 10);
            try player_numbers.append(player_number);
        }
    }

    // std.debug.print("\n{any}", .{ winning_numbers.items });
    // std.debug.print("\n{any}", .{ player_numbers.items });

    var count_winning_numbers: u8 = 0;
    for(player_numbers.items) |pn| {
        for(winning_numbers.items) |wn| {
            if (pn == wn) {
                count_winning_numbers += 1;
            }
        }    
    }
    return count_winning_numbers;
}


fn recurse(depth: u64, card_idx: u32, total_count: u32, card_win_count_map: *std.AutoHashMap(u32, u32)) u32 {
    // std.debug.print("\n", .{});
    // for(0..depth) |_| {
    //     std.debug.print("  ", .{});
    // }
    // std.debug.print("→ [{d}] Process Card {d}", .{ depth, card_idx });
    const winning_count: u32 = card_win_count_map.get(card_idx).?;
    // std.debug.print("\n", .{});
    // for(0..depth) |_| {
    //     std.debug.print("  ", .{});
    // }
    // std.debug.print("  Found {d} winning cards", .{ winning_count });
    if (winning_count == 0) {
        return total_count;
    }
    const next_depth = depth + 1;
    var recurse_count: u32 = winning_count;
    for((card_idx + 1)..(card_idx + 1 + winning_count)) |i| {
        recurse_count += recurse(next_depth, @intCast(i), total_count, card_win_count_map);
    }
    return recurse_count;
}

fn part2(allocator: Allocator, input: []const u8) anyerror!void {
    var card_win_count_map = std.AutoHashMap(u32, u32).init(allocator);

    var total_cards: u32 = 0;
    var cards_it = std.mem.tokenize(u8, input, "\n");
    var cards_idx: u32 = 0;

    // 1. Build map: card nr → win count 
    while(cards_it.next()) |card| {
        std.debug.print("\n\n{d}: {s}", .{ cards_idx, card });
        const won_cards = winning_card_count(allocator, card) catch 0;
        try card_win_count_map.put(cards_idx, won_cards);
        cards_idx += 1;
    }
    total_cards += cards_idx;

    // 2. Recurse
    std.debug.print("\n\n", .{});
    cards_it.reset();
    for(0..total_cards) |i| {
        const card = cards_it.next().?;
        std.debug.print("\n\n{d}: {s}", .{ i, card });
        const won_cards = recurse(0, @intCast(i), 0, &card_win_count_map);
        std.debug.print("\n--- {d}", .{ won_cards });
        total_cards += won_cards;
    }

    std.debug.print("\n\n# Cards: {d}", .{ total_cards });
    std.debug.print("\n--------------", .{});

}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    try aoc.runDay(allocator, 2023, 4, .PUZZLE, part1, part2);
}
