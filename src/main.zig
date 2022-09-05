const std = @import("std");

const trees = @import("./lib/trees.zig");

pub fn main() anyerror!void {
  std.log.info("lawl", .{});
  const root = trees.Node{ .value = .none };
  std.log.info("{}", .{ root.value });
}

test "" {
}
