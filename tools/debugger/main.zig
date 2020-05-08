const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");
const zig_serial = @import("serial");

const BusAddress = u24;

pub fn main() anyerror!u8 {
    const cli_args = try argsParser.parseForCurrentProcess(struct {
        // This declares long options for double hyphen
        @"port-name": ?[]const u8 = if (std.builtin.os.tag == .linux) "/dev/ttyUSB0" else null,

        // This declares short-hand options for single hyphen
        pub const shorthands = .{
            .P = "port-name",
        };
    }, std.heap.page_allocator);
    defer cli_args.deinit();

    if (cli_args.positionals.len != 0) {
        try std.io.getStdOut().outStream().writeAll("Positional arguments are not allowed.\n");
        return 1;
    }

    if (cli_args.options.@"port-name" == null) {
        try std.io.getStdOut().outStream().writeAll("Serial port name is required.\n");
        return 1;
    }

    var serial = std.fs.cwd().openFile(cli_args.options.@"port-name".?, .{ .read = true, .write = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try std.io.getStdOut().outStream().print("The serial port {} does not exist.\n", .{cli_args.options.@"port-name"});
            return 1;
        },
        else => return err,
    };
    defer serial.close();

    try zig_serial.configureSerialPort(serial, zig_serial.SerialConfig{
        .baud_rate = 19200,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
        .word_size = 8,
    });

    const stdin = std.io.getStdIn().inStream();
    const stdout = std.io.getStdOut().outStream();

    const serin = serial.inStream();
    const serout = serial.outStream();

    var inputbuf: [256]u8 = undefined;
    while (true) {
        try stdout.writeAll(">");

        var cmd = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
            try stdout.writeAll("quit\n");
            break;
        };

        try zig_serial.flushSerialPort(serial, true, true);

        if (std.mem.eql(u8, cmd, "quit")) {
            break;
        } else if (std.mem.eql(u8, cmd, "reset")) {
            try serout.writeByte('R');
        } else if (std.mem.eql(u8, cmd, "halt")) {
            try serout.writeByte('H');
        } else if (std.mem.eql(u8, cmd, "resume")) {
            try serout.writeByte('h');
        } else if (std.mem.eql(u8, cmd, "write8")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(BusAddress, addrstr, 16)) |addr| {
                try stdout.writeAll("value   = ");
                var valstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                    break;
                };
                if (std.fmt.parseInt(u8, valstr, 16)) |value| {
                    try serout.writeByte('B');
                    try serout.writeIntLittle(BusAddress, addr);
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
            if (std.fmt.parseInt(BusAddress, addrstr, 16)) |addr| {
                try stdout.writeAll("value   = ");
                var valstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                    break;
                };
                if (std.fmt.parseInt(u16, valstr, 16)) |value| {
                    try serout.writeByte('W');
                    try serout.writeIntLittle(BusAddress, addr);
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
            if (std.fmt.parseInt(BusAddress, addrstr, 16)) |addr| {
                try serout.writeByte('b');
                try serout.writeIntLittle(BusAddress, addr);

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
            if (std.fmt.parseInt(BusAddress, addrstr, 16)) |addr| {
                try serout.writeByte('w');
                try serout.writeIntLittle(BusAddress, addr);

                const value = try serin.readIntLittle(u16);

                try stdout.print("value   = {x}\n", .{
                    value,
                });
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "watch16")) {
            try stdout.writeAll("address = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(BusAddress, addrstr, 16)) |addr| {
                var last: ?u16 = null;
                while (true) {
                    try serout.writeByte('w');
                    try serout.writeIntLittle(BusAddress, addr);

                    const value = try serin.readIntLittle(u16);

                    if (last == null or last.? != value) {
                        try stdout.print("value   = {x}\n", .{
                            value,
                        });
                    }
                    last = value;
                }
            } else |err| {
                try stdout.print("failed to parse address: {}'\n", .{err});
            }
        } else if (std.mem.eql(u8, cmd, "load")) {
            try stdout.writeAll("hex-file = ");
            var filepath = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };

            if (std.fs.cwd().openFile(filepath, .{ .read = true, .write = false })) |file| {
                defer file.close();

                const HexParser = struct {
                    const Self = @This();
                    const Error = error{InvalidHexFile} || std.os.WriteError;

                    input: *const @TypeOf(serin),
                    output: *const @TypeOf(serout),

                    fn verify(p: *const Self, offset: u32, data: []const u8) Error!void {
                        if (offset + data.len >= 0x10000)
                            return error.InvalidHexFile;
                    }

                    fn load(p: *const Self, base: u32, data: []const u8) Error!void {
                        std.debug.assert(base + data.len < 0x10000);
                        for (data) |value, offset| {
                            try p.output.writeByte('B');
                            try p.output.writeIntLittle(BusAddress, @intCast(BusAddress, base + offset));
                            try p.output.writeIntLittle(u8, value);
                        }
                    }
                };

                const parseMode = ihex.ParseMode{
                    .pedantic = true,
                };

                const parser = HexParser{
                    .input = &serin,
                    .output = &serout,
                };

                if (ihex.parseData(file.inStream(), parseMode, &parser, HexParser.Error, HexParser.verify)) |_| {
                    try file.seekTo(0);

                    try stdout.writeAll("starting transfer...\n");
                    const entry_point = try ihex.parseData(file.inStream(), parseMode, &parser, HexParser.Error, HexParser.load);
                    if (entry_point) |ep| {
                        try stdout.print("hex loading done, entry point = 0x{X}\n", .{ep});
                    } else {
                        try stdout.writeAll("hex loading done.\n");
                    }
                } else |err| switch (err) {
                    error.InvalidHexFile => try stdout.print("invalid hex file: {}\n", .{filepath}),
                    else => return err,
                }
            } else |err| switch (err) {
                error.FileNotFound => {
                    try stdout.print("file {} not found.\n", .{filepath});
                },
                else => return err,
            }
        } else if (std.mem.eql(u8, cmd, "bench")) {
            {
                var i: usize = 0;
                var hash = std.hash.Adler32.init();
                while (i < 0x8000) : (i += 1) {
                    hash.update(std.mem.asBytes(&i));

                    try serout.writeByte('B');
                    try serout.writeIntLittle(BusAddress, @intCast(BusAddress, 0x8000 + i));
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
                    try serout.writeIntLittle(BusAddress, @intCast(BusAddress, 0x8000 + i));
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
        } else if (std.mem.eql(u8, cmd, "graphics")) {
            try stdout.writeAll("color(0..15) = ");
            var addrstr = if (try stdin.readUntilDelimiterOrEof(&inputbuf, '\n')) |c| c else {
                break;
            };
            if (std.fmt.parseInt(u4, addrstr, 10)) |color| {
                var i: usize = 0x8000;

                while (i < 0x1_0000) : (i += 1) {
                    try serout.writeByte('B');
                    try serout.writeIntLittle(BusAddress, @intCast(BusAddress, i));
                    try serout.writeIntLittle(u8, color);
                }
            } else |err| {
                try stdout.print("failed to parse color: {}'\n", .{err});
            }
        } else if (cmd.len == 0) {
            // nop
        } else {
            try stdout.print("unknown command '{}'\n", .{cmd});
        }
    }
    try stdout.writeAll("end of debugging session. have a nice day!\n");

    return 0;
}
