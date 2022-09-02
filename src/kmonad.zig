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

  pub fn addLayer(self: *Self, layer: layers.Layer) !void {
    try self.layers.put(layer.name, layer);
  }
};

test "create" {
  var kmonad = Kmonad.init(std.testing.allocator);
  defer kmonad.deinit();
}

test "add layer" {
  var kmonad = Kmonad.init(std.testing.allocator);
  defer kmonad.deinit();
  var layer = layers.Layer.init(std.testing.allocator, "aoeu");
  defer layer.deinit();
  try kmonad.addLayer(layer);
  const name = kmonad.layers.get("aoeu").?.name;
  try std.testing.expect(std.mem.eql(u8, name, "aoeu"));
}

test "" {
}
