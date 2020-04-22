// Exercise 5-3
// This program should open the specified filename (creating it if necessary) and append
// `num-bytes` bytes to the file by using `write()` to write a byte at a time. By default the
// program should open the file with the `O_APPEND` flag, but if a third command-line argmuent
// (`x`) is supplied, then the `O_APPEND` flag should be ommitted, and instead the program should
// perform an `lseek(fd, 0, SEEK_END)` call before each `write()`. Run two instances of this
// program at the same time without the `x` argument to write 1 million bytes to the same file:
//
//    $ ./exercise_5-3 f1 1000000 & ./exercise_5-3 f1 1000000
//
// Repeat the same steps, writing to a different file, but this time specifying the `x` argument:
//
//    $ ./exercise_5-3 f2 1000000 x & ./exercise_5-3 f2 1000000 x
//
// List the sizes of the files using `ls -l` and explain the difference.

const std = @import("std");
const os = std.os;
const mem = std.mem;
const warn = std.debug.warn;

const BUFFER = [_]u8{97}; // 'a'
const FILE_PERMS = os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IWGRP | os.S_IROTH | os.S_IWOTH; // rw-rw-rw-

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const args = try std.process.argsAlloc(&arena.allocator);

    if (args.len < 3 or mem.eql(u8, args[1], "--help")) {
        warn("Usage: filename num-bytes [x]\n", .{});
        return 1;
    }

    const num_bytes = try std.fmt.parseUnsigned(usize, args[2], 10);
    const x_set = args.len == 4 and mem.eql(u8, args[3], "x");

    const extra_flag: u32 = if (x_set) 0 else os.O_APPEND;
    const fd = try os.open(args[1], extra_flag | os.O_WRONLY | os.O_CREAT, FILE_PERMS);

    var i: usize = 0;

    while (i < num_bytes) : (i += 1) {
        if (x_set) {
            try os.lseek_END(fd, 0);
        }

        _ = try os.write(fd, &BUFFER);
    }

    return 0;
}
