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
- Implement carry+appendix bit in CPU

## Tooling Changes
- Support new debug features
- Create small boot rom
- Rewrite assembler with support for new features:
  - (recursive) include files
  - simple assembler macros
  - redefine some mnemonics and modifiers
- Implement carry+appendix bit in assembler + emulator

## Documentation Change
- Write about common patterns in AN000