const std = @import("std");

const layers = @import("./layers.zig");

pub const Kmonad = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  layers: std.StringHashMap(layers.Layer),

  pub fn init(alc: std.mem.Allocator) Self {
    return .{
      .allocator = alc,
      .layers = std.StringHashMap(layers.Layer).init(alc),
    };
  }

  pub fn deinit(self: *Self) void {
    var iter = self.layers.valueIterator();
    while (iter.next()) |layer| {
      layer.deinit();
    }
    self.layers.deinit();
  }
};

test "create" {
  var kmonad = Kmonad.init(std.testing.allocator);
  defer kmonad.deinit();
}

test "" {
}
