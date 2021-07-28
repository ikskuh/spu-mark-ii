#!/bin/bash
set -e

clear
zig build
./zig-out/bin/assembler --format ihex --output /tmp/demo.hex apps/web-firmware/main.asm
./zig-out/bin/emulator /tmp/demo.hex "$@"
