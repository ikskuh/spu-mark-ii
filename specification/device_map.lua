local function Register(name, offset, size, access, desc)
  local reg = {
    name = name or error("requires name!"),
    offset = tonumber(offset) or error("requires offset!"),
    size = tonumber(size) or error("requires size!"),
    access = tostring(access) or error("requires access"),
    desc = desc or "Missing description",
  }
  if reg.size ~= 1 and reg.size ~= 2 then
    error("size must be 1 or 2")
  end
  if reg.access ~= "R" and reg.access ~= "W" and reg.access ~= "RW" then
    error ("access must be R, W or RW")
  end
  return reg
end

local device_map = {
  {
    name  = "MMU",
    reg16 = 18,
    url = "mmu.md",
  },
  {
    name  = "IRQ",
    registers = {
      Register("IRQ0",   0, 2, "R", "Active IRQs 0…15"),
      Register("IRQ1",   2, 2, "R", "Active IRQs 16…31"),
      Register("ACK0",   4, 2, "W", "Acknowledge IRQs 0…15"),
      Register("ACK1",   6, 2, "W", "Acknowledge IRQs 16…31"),
      Register("MASK0",  8, 2, "RW", "Mask IRQs 0…15"),
      Register("MASK1", 10, 2, "RW", "Mask IRQs 16…31"),
    },
    url = "irq.md",
  },
  {
    name  = "UART 16C550-Style",
    count = 4,
    registers = {
      Register("RBR",   0, 1, "R", "Receiver buffer (read), transmitter holding register (write)"),
      Register("IER",   1, 1, "RW", "Interrupt enable register"),
      Register("IIR",   2, 1, "R", "Interrupt identification register (read only)"),
      Register("LCR",   3, 1, "RW", "Line control register"),
      Register("MCR",   4, 1, "RW", "Modem control register"),
      Register("LSR",   5, 1, "R", "Line status register"),
      Register("MSR",   6, 1, "RW", "Modem status register"),
      Register("SCR",   7, 1, "R", "Scratch register"),
    },
    url = "uart.md",
    gpio = { "RXD", "TXD", "RTS", "CTS", "DTR", "DSR", "DCD", "RI" },
  },
  {
    name  = "PS/2",
    count = 2,
    reg16 = 2,
    url = "ps2.md",
    gpio = { "DATA", "CLK" } ,
  },
  {
    name  = "IDE / PATA",
    reg16 = 8,
    url = "ide.md",
    gpio = {
      "RESET",
      "A0",
      "A1",
      "A2",
      "D0",
      "D1",
      "D2",
      "D3",
      "D4",
      "D5",
      "D6",
      "D7",
      "D8",
      "D9",
      "D10",
      "D11",
      "D12",
      "D13",
      "D14",
      "D15", 
      "DMARQ", 
      "DMACK", 
      "DIOW", 
      "DIOR",
      "IORDY",
      "INTRQ",
      "IOCS16",
      "CS0",
      "CS1" 

      -- These are most likely not required
      -- "CABLE SELECT",
      -- "PDIAG",
      -- "DASP",
    },
  },
  {
    name  = "Timer",
    count = 2,
    reg16 = 4,
    url = "timer.md",
  },
  {
    name  = "RTC",
    reg8  = 8,
    reg16 = 3,
    url = "rtc.md",
  },
  {
    name  = "Joystick",
    count = 2,
    reg8  = 1,
    url = "joystick.md",
    gpio = { "UP","DOWN","LEFT","RIGHT","FIRE" },
  },
  {
    name  = "Parallel Port",
    reg8  = 3,
    url = "parport.md",
    gpio = { "D0", "D1", "D2", "D3", "D4", "D5", "D6", "D7", "ACK", "BUSY", "PE", "SEL", "AUTOFD", "ERROR", "INIT", "SELIN", "STROBE" },
  },
  {
    name = "PCM Audio Control/Status",
    url = "pcm.md",
    gpio = { "MCLK", "LR", "BCK", "DATA" },
  },
  {
    name = "DMA Control/Status",
    url = "dma.md",
  },
  {
    name = "VGA Card",
    reg16 = 3,
    reg8  = 2,
    url = "vga.md",
    gpio = { "HSYNC", "VSYNC", "R7", "R6", "R5", "R4", "R3", "G7", "G6", "G5", "G4", "G3", "G2", "B7", "B6", "B5", "B4", "B3" }
  },
  {
    name = "Ethernet",
    reg8 = 7,
    reg16 = 3,
    url = "eth.md",
    gpio = { "MISO", "MOSI", "SCK", "CS" },
  },
  {
    name = "VGA Palette Memory",
    reg16 = 256,
    align = 512,
    url = "vga.md",
  },
}


for i,v in ipairs(device_map) do
  v.count = v.count or 1

  if v.registers then
    assert(v.reg8 == nil, "reg8 must not be set when registers is used!")
    assert(v.reg16 == nil, "reg16 must not be set when registers is used!")
    
    v.reg8 = 0
    v.reg16 = 0

    for _,reg in ipairs(v.registers) do
      if reg.size == 1 then
        v.reg8 = v.reg8 + 1
      elseif reg.size == 2 then
        v.reg16 = v.reg16 + 1
      else
        error("invalid register size!")
      end
    end
  end

  v.reg8  = v.reg8 or 0
  v.reg16 = v.reg16 or 0
  v.gpio = v.gpio or { }
  assert(v.name)
end

return device_map