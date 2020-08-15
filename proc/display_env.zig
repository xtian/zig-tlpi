const std = @import("std");

pub fn main() !u8 {
    const stdout = std.io.getStdOut().outStream();

    for (std.os.environ) |ep| {
        try stdout.print("{}\n", .{ ep });
    }

    return 0;
}
