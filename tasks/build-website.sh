#!/bin/bash
set -e
clear
zig build install firmware wasm
mkdocs build
cp zig-out/lib/emulator.wasm website-out/livedemo/emulator.wasm
cp -r website/* website-out/livedemo/
