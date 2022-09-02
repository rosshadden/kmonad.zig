const std = @import("std");

const Layer = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  name: []const u8,
  keys: std.StringHashMap([:0]const u8),

  pub fn init(alc: std.mem.Allocator, name: []const u8) Self {
    return .{
      .allocator = alc,
      .name = name,
      .keys = std.StringHashMap([:0]const u8).init(alc),
    };
  }

  pub fn deinit(self: *Self) void {
    self.keys.deinit();
  }
};

test "create" {
  const layer = Layer.init(std.testing.allocator, "aoeuaoeuaoeuaoeu");
  try std.testing.expect(std.mem.eql(u8, layer.name, "aoeuaoeuaoeuaoeu"));
}

test "add key" {
  var layer = Layer.init(std.testing.allocator, "aoeu");
  defer layer.deinit();
  try layer.keys.put("a", "b");
  if (layer.keys.get("a")) |value| {
    try std.testing.expect(std.mem.eql(u8, value, "b"));
    try std.testing.expect(true);
  } else {
    try std.testing.expect(false);
  }
}

test "" {
  // std.debug.print("\n{}\n", .{ @TypeOf("foo") });
}
