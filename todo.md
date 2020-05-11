## ISA Changes
- Refine interrupt handling
- Add instruction `cpuid`
- Add instruction `cpuctrl` (reset, halt, soft-interrupt, ...)

## SOC Changes
- Design and calculate GPU
  x Add basic VGA module (only "background color")
  x 640x480 VGA resolution
  x 256×128 pixel output
  - 64-Color RGB (RGB222)
  - Use 4 bit dual port frame buffer RAM 
- Finalize blitter design (see vchip.md)
- Finalize sprite design (see vga.md)
- Make bus mastering configurable

- FIX: EBR ROM is zero all the time :(
- ADD: Read CPU registers via CMD
- ADD: Write CPU registers via CMD

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
  - break
  - inspect/write registers
  - restart
- Add feature: Load ihex with offset / banking (16 MB memory space vs. 64k)


## Documentation Change
- Write about common patterns in AN000

## Website
- Improve *Try it!*
  - Add assembler
  - Add controls
  - Add hex view


<xTr1m> To overcome the 64k memory limitation own to 16 bit cpus is overcome by a paging...

<xTr1m> The SPU Mark II uses the little endian encoding, so the less significant byte is at the lower address, the more significant byte at the higher address.
<xTr1m> bit, not byte
<xTr1m> least significant bit, most significant bit

<xTr1m> ist der MSB bei LOAD8 undefined?
