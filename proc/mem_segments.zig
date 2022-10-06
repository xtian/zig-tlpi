const std = @import("std");
const c = std.c;
const print = std.debug.print;

const glob_buf: [65536]u8 = undefined; // uninitialized data segment
const primes = [_]usize{ 2, 3, 5, 7 }; // initialized data segment

pub fn main() !u8 { // argv allocated in frame for main()
    const key = 9973; // initialized data segment
    const mbuf: [10240000]u8 = undefined; // uninitialized data segment
    var p: *anyopaque = undefined; // allocated in frame for main()

    _ = mbuf;

    p = c.malloc(1024).?; // points to memory in heap segment

    do_calc(key);

    return 0;
}

fn square(x: usize) usize { // allocated in frame in square()
    var result: usize = undefined; // allocated in frame for square()

    result = x * x;
    return result; // return value passed via register
}

fn do_calc(val: usize) void { // allocated in frame for do_calc
    print("The square of {} is {}\n", .{ val, square(val) });

    if (val < 1000) {
        const t = val * val * val; // allocated in frame for do_calc();
        print("The cube of {} is {}\n", .{ val, t });
    }
}
