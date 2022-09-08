const std = @import("std");

const kmonad = @import("./lib/kmonad.zig");

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const alc = gpa.allocator();

  var kmon = kmonad.Kmonad.init(alc);
  defer kmon.deinit();

  const lisp = try kmon.config.toLisp(alc);
  defer alc.free(lisp);
  std.debug.print("{s}\n", .{ lisp });
}

test "" {
}
