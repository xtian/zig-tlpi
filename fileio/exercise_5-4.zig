// Exercise 5-4
// Implement `dup()` and `dup2()` using `fcntl()` and, where necessary, `close()`. (You may ignore)
// the fact that `dup2()` and `fcntl()` return different `errno` values for some error cases.) For
// `dup2()`, remember to handle the special case where `oldfd` equals `newfd`. In this case, you
//  should check whether `oldfd` is valid, which can be done by, for example, checking if
// `fcntl(oldfd, F_GETFL)` succeeds. If `oldfd` is not valid, then the function should return -1
// with `errno` set to `EBADF`.

const std = @import("std");
const assert = std.debug.assert;
const c = std.c;
const os = std.os;

export fn dup(oldfd: c.fd_t) c_int {
    if (os.fcntl(oldfd, os.F_DUPFD, 0)) |newfd| {
        return @intCast(c.fd_t, newfd);
    } else |_| {
        c._errno().* = os.EBADF;
        return -1;
    }
}

export fn dup2(oldfd: c.fd_t, newfd: c.fd_t) c_int {
    if (!fd_is_valid(oldfd)) {
        c._errno().* = os.EBADF;
        return -1;
    }

    if (oldfd == newfd) return newfd;
    if (fd_is_valid(newfd)) os.close(newfd);

    if (os.fcntl(oldfd, os.F_DUPFD, @intCast(u64, newfd))) |ret| {
        if (ret == newfd) {
            return newfd;
        } else {
            return -1;
        }
    } else |_| {
        return -1;
    }
}

fn fd_is_valid(fd: c.fd_t) bool {
    return c.getErrno(c.fcntl(fd, os.F_GETFD)) != os.EBADF;
}

test "dup" {
    const fd = try os.open("/tmp/foo", os.O_WRONLY | os.O_CREAT, 0);
    const new_fd = dup(@as(c.fd_t, fd));

    try os.lseek_SET(fd, 10_000);

    const new_offset = try os.lseek_CUR_get(new_fd);

    assert(new_offset == 10_000);
}

test "dup2" {
    const fd = try os.open("/tmp/foo", os.O_WRONLY | os.O_CREAT, 0);
    const new_fd = dup2(fd, @as(c_int, 3));

    assert(new_fd == 3);
}

test "dup2: invalid old_fd" {
    const ret = dup2(100, 101);

    assert(ret == -1);
    assert(c.getErrno(-1) == os.EBADF);
}
