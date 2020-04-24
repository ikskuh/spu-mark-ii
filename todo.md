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

## Tooling Changes
x Add ihex loader to debug-pc
- Support new debug features
- Create small boot rom
- Rewrite assembler with support for new features:
  - (recursive) include files
  - simple assembler macros
  - redefine some mnemonics and modifiers

## Documentation Change
- Document stack growth direction (downwards stack)
- Document that most instructions (`ipget`, ...) now supports offsets (Misses in "Gets a pointer to the next instruction after the current opcode")
- Explain difference between *stack frame* and *stack* or search better word for *stack frame*
- Explain intended use of `get`, `set` and `BP` in [AN001 - Calling Conventions](./documentation/app-notes/AN002 - Standard Calling Convention.md)
- input1[7:0] instead of input1 and 0xFF
- `FL` is now `FR`
- Improve pseudo code specification, maybe use more python-like or something
- Write about common patterns in AN000
- Write AN001