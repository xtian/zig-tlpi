const std = @import("std");
const os = std.os;
const warn = std.debug.warn;

pub fn main() !u8 {
    if (os.argv.len != 2 or std.cstr.cmp(os.argv[1], "--help") == 0) {
        warn("Usage: file\n", .{});
        return 1;
    }

    const stdout = std.io.getStdOut().outStream();
    const fd = try os.openZ(os.argv[1], os.O_RDONLY, 0);

    var my_struct: os.Stat = undefined;
    var x: usize = undefined;
    var string: [100]u8 = undefined;

    const iov = [_]os.iovec{
        .{ .iov_base = @ptrCast([*]u8, &my_struct), .iov_len = @sizeOf(@TypeOf(my_struct)) },
        .{ .iov_base = @ptrCast([*]u8, &x), .iov_len = @sizeOf(@TypeOf(x)) },
        .{ .iov_base = @ptrCast([*]u8, &string), .iov_len = @sizeOf(@TypeOf(string)) },
    };

    const total_required = iov[0].iov_len + iov[1].iov_len + iov[2].iov_len;
    const num_read = try os.readv(fd, &iov);

    if (num_read < total_required) try stdout.print("Read fewer bytes than requested\n", .{});

    try stdout.print("total bytes requested: {}; bytes read: {}\n", .{ total_required, num_read });

    return 0;
}
