#!/bin/bash
set -e

clear
zig build
./zig-out/bin/assembler --format ihex --output /tmp/firmware.hex apps/web-firmware/main.asm
./zig-out/bin/assembler --format ihex --output /tmp/demo.hex apps/web-firmware/demo.asm

clear

echo "demo application:"
cat /tmp/demo.hex

echo "" # empty line

./zig-out/bin/emulator /tmp/firmware.hex "$@"
