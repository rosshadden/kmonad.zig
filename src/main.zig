const std = @import("std");

const kmonad = @import("./lib/kmonad.zig");

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const alc = gpa.allocator();

  var kmon = kmonad.Kmonad.init(alc);
  defer kmon.deinit();

  // std.debug.print("{s}\n", .{ try kmon.config.toLisp() });
}

test "" {
}
