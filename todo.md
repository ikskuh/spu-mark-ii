## ISA Changes
- Refine interrupt handling

## SOC Changes
- Design and calculate GPU
  - Add basic VGA module (only "background color")
  - 320×240 VGA resolution
  - 256×128 pixel output
  - 8-Color RGB (RGB111)
  - Use 4 bit dual port frame buffer RAM 
- Finalize blitter design (see blitter.md)
- Finalize sprite design (see sprite-unit.md)
- Make bus mastering configurable
- Implement MMU

## Firmware changes
- add monitor features
  - hex dump
  - read/write adresses

## Tooling Changes
- Rewrite assembler with support for new features:
  - allow expression evaluation
    - Implement function evaluation
  - improve error reporting
  - Refine function call syntax `#bswap()` to have simpler parsing
- Support new debug features

## Documentation Change
- Write about common patterns in AN000

## Website
- Improve *Try it!*
  - Add assembler
  - Add controls
  - Add hex view