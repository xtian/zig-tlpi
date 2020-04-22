// Exercise 5-6
// After each of the calls to `write()` in the following code, explain what the content of the
// output file would be, and why.

const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;
const os = std.os;

const FILE = "./foo";
const FLAGS = os.O_RDWR | os.O_CREAT | os.O_TRUNC;
const FILE_PERMS = os.S_IRUSR | os.S_IWUSR;

test "Exercise 5-6" {
  const fd1 = try os.open(FILE, FLAGS, FILE_PERMS);
  const fd2 = 3;
  const fd3 = try os.open(FILE, os.O_RDWR, 0);

  try os.dup2(fd1, fd2);

  _ = try os.write(fd1, "Hello,");
  try assert_contents("Hello,");

  _ = try os.write(fd2, " world");
  try assert_contents("Hello, world"); // file offset of duplicated fd2 set to 6 via write to fd1

  _ = try os.lseek_SET(fd2, 0);

  _ = try os.write(fd1, "HELLO,");
  try assert_contents("HELLO, world"); // file offset was set to 0 via lseek on fd2

  _ = try os.write(fd3, "Gidday");
  try assert_contents("Gidday world"); // fd3 file offset is not shared, so still at 0
}

fn assert_contents(string: []const u8) !void {
  const file = try fs.cwd().openFile(FILE, fs.File.OpenFlags{});
  var buf : [100]u8 = undefined;

  const read = try file.readAll(&buf);

  assert(std.mem.eql(u8, string, buf[0..read]));
}
