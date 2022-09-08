const std = @import("std");

pub const Atom = union(enum) {
  none,
  root,
  int: usize,
  float: f32,
  bool: bool,
  string: []const u8,
  keyword: []const u8,
};

pub const Node = struct {
  const Self = @This();
  const alc = std.heap.page_allocator;

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

  pub fn initFull(value: Atom, child: ?*Node, next: ?*Node) Self {
    return .{
      .value = value,
      .child = child,
      .next = next,
    };
  }

  pub fn initList(value: Atom, list: []*Node) Self {
    var result = Node{
      .value = value,
      .child = null,
      .next = null,
    };

    var last: *Node = &result;
    for (list) |node, index| {
      if (index == 0) {
        last.setChild(node);
      } else {
        last.setNext(node);
      }
      last = node;
    }

    return result;
  }

  pub fn setChild(self: *Self, node: *Node) void {
    self.child = node;
  }

  pub fn setNext(self: *Self, node: *Node) void {
    self.next = node;
  }

  pub fn toLispImp(self: *Self) ![]const u8 {
    var result = std.ArrayList(u8).init(alc);
    defer result.deinit();

    var current: *Node = self;
    while (true) {
      switch (current.value) {
        .keyword => {
          try result.appendSlice(current.value.keyword);
        },
        .string => try result.appendSlice(current.value.string),
        else => {},
      }

      if (current.child != null) {
        current = current.child.?;
        continue;
      }

      if (current.next != null) {
        current = current.next.?;
        continue;
      }

      if (current.child == null and current.next == null) break;
    }
    return result.toOwnedSlice();
  }

  const ToLispErrors = error {
    OutOfMemory,
  };

  pub fn toLisp(self: *Self) ToLispErrors![]const u8 {
    var result = std.ArrayList(u8).init(alc);
    defer result.deinit();

    // wrap start
    if (self.child != null) {
      try result.append('(');
    }

    switch (self.value) {
      .keyword => try result.appendSlice(self.value.keyword),
      .string => try result.appendSlice(self.value.string),
      else => {},
    }

    if (self.child != null) {
      const lisp = try self.child.?.toLisp();
      try result.append(' ');
      try result.appendSlice(lisp);
    }

    if (self.next != null) {
      try result.append(' ');
      try result.appendSlice(try self.next.?.toLisp());
    }

    // wrap end
    if (self.child != null) {
      try result.append(')');
    }

    return result.toOwnedSlice();
  }
};

test "empty tree" {
  var root = Node{ .value = .none };
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "init" {
  var root = Node.init(.none);
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "init full" {
  var root = Node.initFull(.none, null, null);
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "init list" {
  var root = Node.initList(.{ .keyword = "key" }, &.{
    &Node.init(.{ .int = 0 }),
    &Node.init(.{ .int = 1 }),
    &Node.init(.{ .int = 2 }),
    &Node.init(.{ .int = 3 }),
  });
  try std.testing.expect(root.value == .keyword);
  try std.testing.expect(root.child.?.value.int == 0);
  try std.testing.expect(root.child.?.next.?.value.int == 1);
  try std.testing.expect(root.child.?.next.?.next.?.value.int == 2);
  try std.testing.expect(root.child.?.next.?.next.?.next.?.value.int == 3);
}

test "atom none" {
  var root = Node.init(.none);
  try std.testing.expect(root.value == .none);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "atom bool" {
  var root = Node.init(.{ .bool = true });
  try std.testing.expect(root.value == .bool);
  try std.testing.expect(root.value.bool == true);
  try std.testing.expect(root.child == null);
  try std.testing.expect(root.next == null);
}

test "atom int" {
  var root = Node.init(.{ .int = 4 });
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

test "to lisp horizontal" {
  var root = Node.initList(.{ .keyword = "root" }, &.{
    &Node.init(.{ .keyword = "a" }),
    &Node.init(.{ .keyword = "b" }),
    &Node.init(.{ .keyword = "c" }),
  });
  var lisp = try root.toLisp();
  std.debug.print("\n{s}\n", .{ lisp });
  try std.testing.expect(std.mem.eql(u8, try root.toLisp(), "(root a b c)"));
}

test "to lisp vertical" {
  var root = Node.init(.{ .keyword = "root" });
  var child1 = Node.init(.{ .keyword = "a" });
  var child2 = Node.init(.{ .keyword = "b" });
  var child3 = Node.init(.{ .keyword = "c" });
  root.setChild(&child1);
  child1.setChild(&child2);
  child2.setChild(&child3);
  var lisp = try root.toLisp();
  std.debug.print("\n{s}\n", .{ lisp });
  try std.testing.expect(std.mem.eql(u8, try root.toLisp(), "(root (a (b c)))"));
}

test "" {
}
