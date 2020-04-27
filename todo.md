## ISA Changes
- sign extend instruction
- carry bit
- remove `NEG` command, it can be implemented by using `sub` with one input = ZERO

## SOC Changes
- Design and calculate GPU
  - Add basic VGA module (only "background color")
  - 320×240 VGA resolution
  - 256×128 pixel output
  - 8-Color RGB (RGB111)
  - Pixel Fetch Pipeline with buffering for bus delays
- Finalize blitter design (see blitter.md)
- Make bus mastering configurable
- Implement MMU

## Tooling Changes
x Add ihex loader to debug-pc
- Support new debug features
- Create small boot rom
- Rewrite assembler with support for new features:
  - (recursive) include files
  - simple assembler macros
  - redefine some mnemonics and modifiers

## Documentation Change
- Write about common patterns in AN000