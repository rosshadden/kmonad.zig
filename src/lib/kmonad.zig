const std = @import("std");

const layers = @import("./layers.zig");
const trees = @import("./trees.zig");

pub const Config = struct {
  input: trees.Node,
  output: trees.Node,
  fallthrough: bool,
  allow_cmd: bool,
};

pub const Kmonad = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  layers: std.StringHashMap(layers.Layer),
  config: Config,
  config2: trees.Node,

  pub fn init(alc: std.mem.Allocator) Self {
    return .{
      .allocator = alc,
      .layers = std.StringHashMap(layers.Layer).init(alc),

      .config = Config{
        .input = trees.Node.initFull(
          .{ .keyword = "device-file" },
          &trees.Node.init(.{ .string = "/dev/input/by-id/usb-Razer_Razer_BlackWidow_Ultimate-if01-event-kbd" }),
          null
        ),
        .output = trees.Node.initFull(
          .{ .keyword = "uinput-sink" },
          &trees.Node.init(.{ .string = "Kmonad output" }),
          null
        ),
        .fallthrough = true,
        .allow_cmd = true,
      },

      .config2 = trees.Node.initFull(
        .{ .keyword = "defcfg" },
        &trees.Node.init(.none),
        &trees.Node.init(.none),
      ),
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

  // pub fn toTree(self: *Self) trees.Node {
  // }

  // pub fn toLisp(self: *Self) []const u8 {
  // }
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
