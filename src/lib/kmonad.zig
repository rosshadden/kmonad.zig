const std = @import("std");

const layers = @import("./layers.zig");
const trees = @import("./trees.zig");

pub const Kmonad = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  layers: std.StringHashMap(layers.Layer),
  config: trees.Node,

  pub fn init(alc: std.mem.Allocator) Self {
    return .{
      .allocator = alc,
      .layers = std.StringHashMap(layers.Layer).init(alc),

      .config = trees.Node.initList(.{ .keyword = "defcfg" }, &.{
        &trees.Node.init(.{ .keyword = "input" }),
        &trees.Node.initList(.{ .keyword = "device-file" }, &.{
          &trees.Node.init(.{ .string = "/dev/input/by-id/usb-Razer_Razer_BlackWidow_Ultimate-if01-event-kbd" }),
        }),

        &trees.Node.init(.{ .keyword = "output" }),
        &trees.Node.initList(.{ .keyword = "device-file" }, &.{
          &trees.Node.init(.{ .string = "Kmonad output" }),
          &trees.Node.init(.{ .string = "sleep 1 && setxkbmap -option compose:sclk; xmodmap -e 'keycode 131 = Hyper_L' -e 'remove Mod4 = Hyper_L' -e 'add Mod3 = Hyper_L'" }),
        }),

        &trees.Node.init(.{ .keyword = "fallthrough" }),
        &trees.Node.init(.{ .bool = true }),

        &trees.Node.init(.{ .keyword = "allow_cmd" }),
        &trees.Node.init(.{ .bool = true }),
      }),
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
  var kmon = Kmonad.init(std.testing.allocator);
  defer kmon.deinit();
}

test "add layer" {
  var kmon = Kmonad.init(std.testing.allocator);
  defer kmon.deinit();
  var layer = layers.Layer.init(std.testing.allocator, "aoeu");
  defer layer.deinit();
  try kmon.addLayer(layer);
  const name = kmon.layers.get("aoeu").?.name;
  try std.testing.expect(std.mem.eql(u8, name, "aoeu"));
}

test "to lisp vertical" {
  var root = trees.Node.init(.{ .keyword = "root" });
  const lisp = try root.toLisp(std.testing.allocator);
  defer std.testing.allocator.free(lisp);
  std.debug.print("\n{s}\n", .{ lisp });
  try std.testing.expect(std.mem.eql(u8, lisp, "(root)"));
}

test "to lisp" {
  var kmon = Kmonad.init(std.testing.allocator);
  defer kmon.deinit();
  const lisp = try kmon.config.toLisp(std.testing.allocator);
  defer std.testing.allocator.free(lisp);
  std.debug.print("{s}\n", .{ lisp });
}

test "" {
}
