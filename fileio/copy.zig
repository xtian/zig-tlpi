const std = @import("std");
const os = std.os;
const warn = std.debug.warn;

const BUFFER_SIZE = 1024;

const OPEN_FLAGS = os.O_CREAT | os.O_WRONLY | os.O_TRUNC;
const FILE_PERMS = os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IWGRP | os.S_IROTH | os.S_IWOTH; // rw-rw-rw-

pub fn main() !u8 {
    if (os.argv.len != 3 or std.cstr.cmp(os.argv[1], "--help") == 0) {
        warn("Usage: old-file new-file\n", .{});
        return 1;
    }

    // Open input and output files

    const input_fd = try os.openZ(os.argv[1], os.O_RDONLY, 0);
    defer os.close(input_fd);

    const output_fd = try os.openZ(os.argv[2], OPEN_FLAGS, FILE_PERMS);
    defer os.close(output_fd);

    // Transfer data until we encounter end of input or an error

    var buffer: [BUFFER_SIZE]u8 = undefined;

    while (os.read(input_fd, &buffer)) |bytes_read| {
        if (bytes_read == 0) break;

        if (os.write(output_fd, buffer[0..bytes_read])) |bytes_written| {
            if (bytes_written != bytes_read) {
                warn("Error: couldn't write whole buffer ({} != {})", .{ bytes_written, bytes_read });
                return 1;
            }
        } else |err| {
            warn("Error: write {}", .{err});
            return 1;
        }
    } else |err| {
        warn("Error: read {}", .{err});
        return 1;
    }

    return 0;
}
