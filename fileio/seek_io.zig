const std = @import("std");
const os = std.os;
const print = std.debug.print;

const FILE_PERMS = os.S.IRUSR | os.S.IWUSR | os.S.IRGRP | os.S.IWGRP | os.S.IROTH | os.S.IWOTH; // rw-rw-rw-

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);

    if (args.len < 3 or std.mem.eql(u8, args[1], "--help")) {
        print("Usage: file [r<length>|R<length>|w<string>|s<offset>]...\n", .{});
        return 1;
    }

    const stdout = std.io.getStdOut().writer();
    const fd = try os.open(args[1], os.O.RDWR | os.O.CREAT, FILE_PERMS);

    for (args[2..]) |arg| {
        switch (arg[0]) {
            // Display bytes at current offset, as text or hex
            'r', 'R' => {
                const length = try std.fmt.parseUnsigned(usize, arg[1..], 10);
                const buffer = try allocator.alloc(u8, length);

                const bytes_read = try os.read(fd, buffer);

                if (bytes_read == 0) {
                    print("{s} end-of-file\n", .{arg});
                } else {
                    try stdout.print("{s}: ", .{arg});

                    for (buffer) |byte| {
                        switch (arg[0]) {
                            'r' => try stdout.print("{c}", .{byte}),
                            'R' => try stdout.print("{x:0>2} ", .{byte}),
                            else => unreachable,
                        }
                    }

                    try stdout.print("\n", .{});
                }
            },
            // Write string at current offset
            'w' => {
                const bytes_written = try os.write(fd, arg[1..]);
                try stdout.print("{s}: wrote {} bytes\n", .{ arg, bytes_written });
            },
            // Change file offset
            's' => {
                const offset = try std.fmt.parseUnsigned(usize, arg[1..], 10);
                try os.lseek_SET(fd, offset);
                try stdout.print("{s}: seek succeeded\n", .{arg});
            },
            else => |char| {
                print("Usage error: Argument must start with [rRws]: {c}\n", .{char});
                return 1;
            },
        }
    }

    return 0;
}
