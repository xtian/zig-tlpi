// Exercise 5-5
// Write a program to verify that duplicated file descriptors share a file offset value and open
// file status flags.

const std = @import("std");
const assert = std.debug.assert;
const os = std.os;

test "dup2" {
    const fd = try os.open("/tmp/foo", os.O_WRONLY | os.O_CREAT, 0);
    const new_fd = 3;

    try os.dup2(fd, new_fd);
    try os.lseek_SET(fd, 10_000);

    const new_offset = try os.lseek_CUR_get(new_fd);

    assert(new_offset == 10_000);

    const fd_flags = try os.fcntl(fd, os.F_GETFL, 0);
    const new_fd_flags = try os.fcntl(new_fd, os.F_GETFL, 0);

    assert(new_fd_flags == fd_flags);
}
