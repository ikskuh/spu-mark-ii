## ISA Changes
- sign extend instruction
- carry bit

## SOC Changes
x Add enable/disable for different bus masters
- Design and calculate GPU
  - Add basic VGA module (only "background color")
  - 320×240 VGA resolution
  - 256×128 pixel output
  - 8-Color RGB (RGB111)
  - Pixel Fetch Pipeline with buffering for bus delays
- Implement get/set opcodes

## Tooling Changes
x Add ihex loader to debug-pc
- Support new debug features
- Create small boot rom

## Documentation Change
- Document stack growth direction (downwards stack)