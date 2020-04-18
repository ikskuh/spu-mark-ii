const std = @import("std");

extern fn configure_serial(fd: c_int) u8;

extern fn flush_serial(fd: c_int) void;

pub fn main() anyerror!void {
    var serial = try std.fs.cwd().openFile("/dev/ttyUSB0", .{ .read = true, .write = true });
    defer serial.close();

    if (configure_serial(serial.handle) != 0)
        return error.InvalidConfiguration;

    const stdin = std.io.getStdIn().inStream();
    const stdout = std.io.getStdOut().outStream();

    const serin = serial.inStream();
    const serout = serial.outStream();

    var inputbuf: [64]u8 = undefined;
    while (true) {
        try stdout.writeAll(">");

        var cmd = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
            try stdout.writeAll("quit\n");
            break;
        };

        flush_serial(serial.handle);

        if (std.mem.eql(u8, cmd, "quit")) {
            break;
        }
        if (std.mem.eql(u8, cmd, "reset")) {
            try serout.writeByte('R');
        } else if (std.mem.eql(u8, cmd, "write8")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(u16, addrstr, 16)) |addr| {
                try stdout.writeAll("value   = ");
                var valstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                    break;
                };
                if (std.fmt.parseInt(u8, valstr, 16)) |value| {
                    try serout.writeByte('B');
                    try serout.writeIntLittle(u16, addr);
                    try serout.writeIntLittle(u8, value);
                } else |err| {
                    try stdout.print("failed to parse value: {}'\n", .{err});
                }
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "write16")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(u16, addrstr, 16)) |addr| {
                try stdout.writeAll("value   = ");
                var valstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                    break;
                };
                if (std.fmt.parseInt(u16, valstr, 16)) |value| {
                    try serout.writeByte('W');
                    try serout.writeIntLittle(u16, addr);
                    try serout.writeIntLittle(u16, value);
                } else |err| {
                    try stdout.print("failed to parse value: {}'\n", .{err});
                }
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "read8")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(u16, addrstr, 16)) |addr| {
                try serout.writeByte('b');
                try serout.writeIntLittle(u16, addr);

                const value = try serin.readIntLittle(u8);

                try stdout.print("value   = {x} '{c}'\n", .{
                    value,
                    if (std.ascii.isPrint(value)) value else '?',
                });
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "read16")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(u16, addrstr, 16)) |addr| {
                try serout.writeByte('w');
                try serout.writeIntLittle(u16, addr);

                const value = try serin.readIntLittle(u16);

                try stdout.print("value   = {x}\n", .{
                    value,
                });
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "bench")) {
            {
                var i: usize = 0;
                var hash = std.hash.Adler32.init();
                while (i < 0x8000) : (i += 1) {
                    hash.update(std.mem.asBytes(&i));

                    try serout.writeByte('B');
                    try serout.writeIntLittle(u16, @intCast(u16, 0x8000 + i));
                    try serout.writeIntLittle(u8, @truncate(u8, hash.final()));

                    if ((i % 0x200) == 0)
                        try stdout.print("\rwrite progress: {d}%", .{(100 * i) / 0x7FFF});
                }
                try stdout.writeAll("\rwrite progress: 100%\n");
            }
            {
                var i: usize = 0;
                var errors: usize = 0;
                var hash = std.hash.Adler32.init();
                while (i < 0x8000) : (i += 1) {
                    hash.update(std.mem.asBytes(&i));

                    try serout.writeByte('b');
                    try serout.writeIntLittle(u16, @intCast(u16, 0x8000 + i));
                    const value = try serin.readIntLittle(u8);
                    if (value != @truncate(u8, hash.final()))
                        errors += 1;
                    if ((i % 0x200) == 0)
                        try stdout.print("\rverify progress: {d}%", .{(100 * i) / 0x7FFF});
                }
                try stdout.writeAll("\rverify progress: 100%\n");
                try stdout.print("verification errors: {} / {d}%\n", .{
                    errors,
                    (100 * errors) / 0x8000,
                });
            }
        } else if (cmd.len == 0) {
            // nop
        } else {
            try stdout.print("unknown command '{}'\n", .{cmd});
        }
    }
    try stdout.writeAll("end of debugging session. have a nice day!\n");
}
