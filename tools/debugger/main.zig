const std = @import("std");
const argsParser = @import("args");
const ihex = @import("ihex");
const zig_serial = @import("serial");

const BusAddress = u24;

pub const NUL = 0x00;
pub const SOH = 0x01;
pub const STX = 0x02;
pub const ETX = 0x03;
pub const EOT = 0x04;
pub const ENQ = 0x05;
pub const ACK = 0x06;
pub const BEL = 0x07;
pub const BS = 0x08;
pub const TAB = 0x09;
pub const LF = 0x0A;
pub const VT = 0x0B;
pub const FF = 0x0C;
pub const CR = 0x0D;
pub const SO = 0x0E;
pub const SI = 0x0F;
pub const DLE = 0x10;
pub const DC1 = 0x11;
pub const DC2 = 0x12;
pub const DC3 = 0x13;
pub const DC4 = 0x14;
pub const NAK = 0x15;
pub const SYN = 0x16;
pub const ETB = 0x17;
pub const CAN = 0x18;
pub const EM = 0x19;
pub const SUB = 0x1A;
pub const ESC = 0x1B;
pub const FS = 0x1C;
pub const GS = 0x1D;
pub const RS = 0x1E;
pub const US = 0x1F;

pub fn main() anyerror!u8 {
    const cli_args = argsParser.parseForCurrentProcess(struct {
        // This declares long options for double hyphen
        @"port-name": ?[]const u8 = if (std.builtin.os.tag == .linux) "/dev/ttyUSB0" else null,

        // This declares short-hand options for single hyphen
        pub const shorthands = .{
            .P = "port-name",
        };
    }, std.heap.page_allocator, .print) catch return 1;
    defer cli_args.deinit();

    if (cli_args.positionals.len != 0) {
        try std.io.getStdOut().writer().writeAll("Positional arguments are not allowed.\n");
        return 1;
    }

    if (cli_args.options.@"port-name" == null) {
        try std.io.getStdOut().writer().writeAll("Serial port name is required.\n");
        return 1;
    }

    var serial = std.fs.cwd().openFile(cli_args.options.@"port-name".?, .{ .read = true, .write = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try std.io.getStdOut().writer().print("The serial port {s} does not exist.\n", .{cli_args.options.@"port-name"});
            return 1;
        },
        else => return err,
    };
    defer serial.close();

    try zig_serial.configureSerialPort(serial, zig_serial.SerialConfig{
        .baud_rate = 460800,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
        .word_size = 8,
    });

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const serin = serial.reader();
    const serout = serial.writer();

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
            try serout.writeByte('r');
        } else if (std.mem.eql(u8, cmd, "system-reset")) {
            try serout.writeByte('R');
        } else if (std.mem.eql(u8, cmd, "halt")) {
            try serout.writeByte('H');
            if ((try serin.readByte()) != ACK) {
                try stdout.writeAll("Failed to halt CPU!\n");
            }
        } else if (std.mem.eql(u8, cmd, "resume")) {
            try serout.writeByte('h');
            if ((try serin.readByte()) != ACK) {
                try stdout.writeAll("Failed to resume CPU!\n");
            }
        } else if (std.mem.eql(u8, cmd, "step")) {
            try serout.writeByte('s');
            if ((try serin.readByte()) != ACK) {
                try stdout.writeAll("Failed to execute step!\n");
            }
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
                        _ = p;
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

                if (ihex.parseData(file.reader(), parseMode, &parser, HexParser.Error, HexParser.verify)) |_| {
                    try file.seekTo(0);

                    try stdout.writeAll("starting transfer...\n");
                    const entry_point = try ihex.parseData(file.reader(), parseMode, &parser, HexParser.Error, HexParser.load);
                    if (entry_point) |ep| {
                        try stdout.print("hex loading done, entry point = 0x{X}\n", .{ep});
                    } else {
                        try stdout.writeAll("hex loading done.\n");
                    }
                } else |err| switch (err) {
                    error.InvalidHexFile => try stdout.print("invalid hex file: {s}\n", .{filepath}),
                    else => return err,
                }
            } else |err| switch (err) {
                error.FileNotFound => {
                    try stdout.print("file {s} not found.\n", .{filepath});
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
            try stdout.print("unknown command '{s}'\n", .{cmd});
        }
    }
    try stdout.writeAll("end of debugging session. have a nice day!\n");

    return 0;
}
