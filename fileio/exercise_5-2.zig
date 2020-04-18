// Exercise 5-2
// Write a program that opens an existing file for writing with the `O_APPEND` flag, and then seeks
// to the beginning of the file before writing some data. Where does data appear in the file? Why?

const std = @import("std");
const os = std.os;
const warn = std.debug.warn;

const FILE_PERMS = os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IWGRP | os.S_IROTH | os.S_IWOTH; // rw-rw-rw-

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const args = try std.process.argsAlloc(&arena.allocator);

    if (args.len != 3 or std.mem.eql(u8, args[1], "--help")) {
        warn("Usage: output-file data\n", .{});
        return 1;
    }

    const fd = try os.open(args[1], os.O_WRONLY | os.O_APPEND, FILE_PERMS);

    try os.lseek_SET(fd, 0);
    _ = try os.write(fd, args[2]);

    return 0;
}
