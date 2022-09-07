const std = @import("std");

pub const Buffer = struct {
  const Self = @This();

  buffer: []u8,

  var pos: usize = 0;
  var len: usize = 0;

  pub fn init() Self {
    return .{
      .buffer = "aoeu",
    };
  }

  pub fn from(value: [:0]const u8) Self {
    var buf = Self.init();
    for (value) |char, i| {
      buf.buffer[i] = char;
    }
    return buf;
  }

  pub fn append(self: *Self, buffer: []const u8) void {
    if (buffer.len + pos > len) {
      const newLen = buffer.len + pos;
      var newBuffer: []u8 = std.heap.c_allocator.alloc(u8, newLen);

      var i: usize = 0;
      while (i < self.buffer.len) {
        newBuffer[i] = self.buffer[i];
        i += 1;
      }
    }
  }
};

test "init" {
  _ = Buffer.init();
}

test "from" {
  // var buf = Buffer.from("lol");
  // try std.testing.expect(std.mem.eql(u8, buf.buffer, "lol"));
}

test "" {
}
