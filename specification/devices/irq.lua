local Datasheet = require "Datasheet"
local Peripherial = require "Peripherial"


return Datasheet {
  id = "irq",
  name = "IRQ Controller",

  registers = Peripherial.RegisterSet {
    Peripherial.Register("IRQ0",   0, 2, "RO", "Active IRQs 0…15") [[
      When read, all IRQs between 0 and 15 that were triggered since the last acknowledge are
      displayed as `1`. All non-triggered IRQs are `0`.
    ]],
    Peripherial.Register("IRQ1",   2, 2, "RO", "Active IRQs 16…31") [[
      When read, all IRQs between 16 and 31 that were triggered since the last acknowledge are
      displayed as `1`. All non-triggered IRQs are `0`.
    ]],
    Peripherial.Register("ACK0",   0, 2, "WO", "Acknowledge IRQs 0…15") [[
       When writing to this register, all bits that are `1` in this register will be acknowledged and reset.
    ]],
    Peripherial.Register("ACK1",   2, 2, "WO", "Acknowledge IRQs 16…31") [[
      When writing to this register, all bits that are `1` in this register will be acknowledged and reset.
   ]],
    Peripherial.Register("MASK0",  4, 2, "RW", "Mask IRQs 0…15") [[
      When a bit is 1, the corresponding interrupt is masked and will not be able to get active. On controller reset, all interrupts are masked.
    ]],
    Peripherial.Register("MASK1",  6, 2, "RW", "Mask IRQs 16…31") [[
      When a bit is 1, the corresponding interrupt is masked and will not be able to get active. On controller reset, all interrupts are masked.
    ]],
  },

  Datasheet.Chapter("Overview") [[
    - Dispatch multiple IRQ lanes into a single lane
    - Acknowledge of IRQs
    - Masking of IRQs
    - up to 32 IRQs
  ]],

  Datasheet.Chapter("Function") [[
    The IRQ controller manages up to 32 different IRQ sources that work with level-driven IRQs.
    If a source IRQ lane is *low*, the IRQ is assumed to be active. A IRQ becomes inactive when the
    source lane will go to *high*.

    When an IRQ becomes active, a corresponding bit is set in the `IRQ0` or `IRQ1` register and the output IRQ lane is pulled to *low*.
    The output IRQ lane is *low* until all bits in the `IRQ0` and `IRQ1` registers are `0`.

    To acknowledge that an IRQ was handled, write a `1` bit into `IRQ0` or `IRQ1` to tell the controller that this interrupt was handled.
    If the IRQ was previously active, it is now disabled.

    Masking interrupts is supported by writing a `1` bit to `MASK0` or `MASK1`. Interrupts will only become active when the IRQ lane is *low* and the corresponding bit in `MASK0` or `MASK1` is `0`. When the controller is reset, all interrupts are masked.
  ]],

  Datasheet.ImplementChapter("Registers", Peripherial.RegisterChapter)
}