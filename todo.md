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
- Finalize blitter design (see sprite-unit.md)
- Make bus mastering configurable
- Implement MMU

## Tooling Changes
- Support new debug features
- Create small boot rom
  - add monitor features
    - hex dump
    - read/write adresses
  - ihex serial loader
- Rewrite assembler with support for new features:
  - (recursive) include files
  - redefine some mnemonics and modifiers
  - allow expression evaluation
  - implement missing
    - `.space`
    - `.include`
    - `.incbin`
    - Expression parsing/arithmetic implementation
  - Refine function call syntax `#bswap()` to have simpler parsing 
  


## Documentation Change
- Write about common patterns in AN000

## Website
- Fill website with contents