local Datasheet = require "Datasheet"
local Peripherial = require "Peripherial"

return Datasheet {
  id = "uart",
  name = "TinyUART",
  brief = "A 16C550 compatible UART component.",

  registers = Peripherial.RegisterSet {
    Peripherial.Register("RBR", 0, 1, "RO", "(DLAB=0) Receiver buffer"),
    Peripherial.Register("THR", 0, 1, "WO", "(DLAB=0) Transmitter holding register"),
    Peripherial.Register("IER", 1, 1, "RW", "(DLAB=0) Interrupt enable register"),
    Peripherial.Register("DLL", 0, 1, "RW", "(DLAB=1) Divisor latch (LSB)"),
    Peripherial.Register("DLM", 1, 1, "RW", "(DLAB=1) Divisor latch (MSB)"),
    Peripherial.Register("IIR", 2, 1, "RO", "Interrupt identification register"),
    Peripherial.Register("FCR", 2, 1, "WO", "FIFO control register"),
    Peripherial.Register("LCR", 3, 1, "RW", "Line control register"),
    Peripherial.Register("MCR", 4, 1, "RW", "Modem control register"),
    Peripherial.Register("LSR", 5, 1, "RO", "Line status register"),
    Peripherial.Register("MSR", 6, 1, "RO", "Modem status register"),
    Peripherial.Register("SCR", 7, 1, "RW", "Scratch register"),
  },

  Datasheet.Chapter("Features") [[
  The TinyUART is a 16C550 compatible UART implementation that provides a fully featured UART interface including flow- and modem control.
  ]],

  Datasheet.ImplementChapter("Registers", Peripherial.RegisterChapter),
}