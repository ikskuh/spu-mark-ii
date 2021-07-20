#!/bin/bash
zig run render-mnemonics.zig \
  --main-pkg-path .. \
  --pkg-begin spu-mk2 ../common/spu-mk2.zig --pkg-end \
  > src/mnemonics.js
