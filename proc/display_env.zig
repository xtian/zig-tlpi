const std = @import("std");

pub fn main() !u8 {
    const stdout = std.io.getStdOut().writer();

    for (std.os.environ) |ep| {
        try stdout.print("{s}\n", .{ep});
    }

    return 0;
}
