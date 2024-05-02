const std = @import("std");

pub extern "wasmapi" fn logU32(s: u32) void;
pub extern "wasmapi" fn logUsize(s: usize) void;
pub extern "wasmapi" fn logStr(s: [*]const u8, len: usize) void;

export fn allocUint8(length: u32) [*]const u8 {
    const slice = std.heap.page_allocator.alloc(u8, length) catch {
        @panic("failed to allocate memory");
    };
    return slice.ptr;
}
