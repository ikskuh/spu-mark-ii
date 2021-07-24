# SPU Mark II Livedemo

<link rel="stylesheet" href="xterm/xterm.css" />
<script src="xterm/xterm.js"></script>

## About

The black box below is an ANSI terminal emulator with an emulated *Ashet* connected to it. Just press `h` to see the available options in the boot rom.

Currently, the emulator runs the [serial BIOS](https://github.com/MasterQ32/spu-mark-ii/blob/master/apps/web-firmware/main.asm) of *Ashet*, as the graphical components are still in development.

<div id="live-terminal"></div>


<!-- 
<code id="live-terminal" tabindex="0">
<pre id="live-terminal-text"></pre><span class="blink">█</span><br />
</code>
-->

<script type="text/javascript" src="livedemo.js"></script>

## Quick start:

Focus the emulator terminal, press `h` to display a short help text from the BIOS. Then press `l` to go into [ihex](https://en.wikipedia.org/wiki/Intel_HEX) loading mode. The *BIOS* now awaits a valid ihex file over the serial port. Paste this text into the terminal:

```ihex
:1080000008011A8008050200081E06001800881DD5
:1080100000406C020E80180018020D48656C6C6FF1
:0A8020002C20576F726C64210000E1
:00000001FF
```

This has loaded a small *Hello World* program into RAM that can now be executed by pressing `g`.

Now you know how to load your own programs, go write one! Starting point is <a href="docs/an000.htm">AN000</a> and
  <a href="docs/an001.htm">AN001</a>, as well as the <a href="docs/isa.htm">ISA description</a>.
</p>

## Memory Layout

The memory layout for the emulator is:

| Memory Range        | Function          |
|---------------------|-------------------|
| `0x0000`…`0x3FFF` | BIOS ROM          |
| `0x4000`…`0x4000` | UART Port. Write to send blockingly, read nonblockingly. No value available returns 0xFFFF. |
| `0x6000`…`0x6FFF` | RAM 0             |
| `0x8000`…`0xFFFF` | RAM 1             |
