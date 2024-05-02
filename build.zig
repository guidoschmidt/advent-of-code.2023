const std = @import("std");

fn createBuildTarget(b: *std.Build, day: u8, optimize: std.builtin.OptimizeMode) void {
    var name_buf: [32]u8 = undefined;
    const name = std.fmt.bufPrint(&name_buf, "aoc_day-{d}", .{day}) catch "aoc";
    var source_file_buf: [32]u8 = undefined;
    const source_file = std.fmt.bufPrint(&source_file_buf, "src/day{d}.zig", .{day}) catch "src/day1.zig";
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source_file },
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        }),
        .optimize = optimize,
    });
    exe.entry = .disabled;
    exe.rdynamic = true;
    exe.import_symbols = true;

    const install_artifact = b.addInstallArtifact(exe, .{ .dest_dir = .{ .override = .{
        .custom = "../web/src/wasm",
        } } });
    b.getInstallStep().dependOn(&install_artifact.step);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    var run_cmd_name_buf: [10]u8 = undefined;
    const run_cmd_name = std.fmt.bufPrint(&run_cmd_name_buf, "run-day{d}", .{day}) catch "run-day1";
    const run_step = b.step(run_cmd_name, "Run the app");
    run_step.dependOn(&run_cmd.step);
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        if (std.mem.eql(u8, args[0], "all")) {
            for (1..24) |day|
                createBuildTarget(b, @intCast(day), optimize);
            return;
        }
        const day = std.fmt.parseInt(u8, args[0], 10) catch 1;
        createBuildTarget(b, day, optimize);
        return;
    }

    // If no argument was given, ask the user which day should be build/run
    std.debug.print("\nWhich day should be build/run [1 - 24]? ", .{});
    // Ideally we would want to issue more than one read
    // otherwise there is no point in buffering.
    var msg_buf: [4096]u8 = undefined;
    const input = r.readUntilDelimiterOrEof(&msg_buf, '\n') catch "";
    if (input) |input_txt| {
        const day = std.fmt.parseInt(u8, input_txt, 10) catch {
            std.debug.print("\nPlease give a number between 1 and 24", .{});
            return;
        };
        std.debug.print("Selected day {d}\n~ Compiling...\n", .{day});
        createBuildTarget(b, day, optimize);
    }
}
