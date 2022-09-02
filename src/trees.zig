const std = @import("std");

const Atom = union(enum) {
  none,
  int: usize,
  float: f32,
  bool: bool,
};

const Node = struct {
  const Self = @This();

  value: Atom,
  child: ?*Node = null,
  next: ?*Node = null,

  pub fn init(value: Atom) Self {
    return .{
      .value = value,
      .child = null,
      .next = null,
    };
  }

  pub fn setChild(self: *Self, node: *Node) void {
    self.child = node;
  }

  pub fn setNext(self: *Self, node: *Node) void {
    self.next = node;
  }
};

test "empty tree" {
  const root = Node{ .value = .none };
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "atom none" {
  const root = Node.init(.none);
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "atom bool" {
  const root = Node.init(.{ .bool = true });
  try std.testing.expect(root.value == .bool);
  try std.testing.expect(root.value.bool == true);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "atom int" {
  const root = Node.init(.{ .int = 4 });
  try std.testing.expect(root.value == .int);
  try std.testing.expect(root.value.int == 4);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "setChild" {
  var root = Node.init(.{ .int = 4 });
  var child = Node.init(.{ .bool = true });
  root.setChild(&child);
  try std.testing.expect(root.value.int == 4);
  try std.testing.expect(root.child.?.value.bool == true);
}

test "setNext" {
  var root = Node.init(.{ .int = 4 });
  var next = Node.init(.{ .bool = true });
  root.setNext(&next);
  try std.testing.expect(root.value.int == 4);
  try std.testing.expect(root.next.?.value.bool == true);
}

test "setChild of next" {
  var root = Node.init(.{ .int = 1 });
  var next = Node.init(.{ .int = 2 });
  var child = Node.init(.{ .int = 3 });
  root.setNext(&next);
  next.setChild(&child);
  try std.testing.expect(root.next.?.child.?.value.int == 3);
}

test "setNext of child" {
  var root = Node.init(.{ .int = 1 });
  var next = Node.init(.{ .int = 2 });
  var child = Node.init(.{ .int = 3 });
  root.setChild(&child);
  child.setNext(&next);
  try std.testing.expect(root.child.?.next.?.value.int == 2);
}

test "" {
}
