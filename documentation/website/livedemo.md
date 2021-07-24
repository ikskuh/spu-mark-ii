# SPU Mark II Livedemo

<link rel="stylesheet" href="xterm/xterm.css" />
<script src="xterm/xterm.js"></script>
<style type="text/css">
#emulator-controls {
  /* border-left: 1px solid black; */
  /* border-right: 1px solid black; */
  /* border-bottom: 1px solid black; */
  /* border-bottom-left-radius: 8px; */
  /* border-bottom-right-radius: 8px; */
  background-color: #00000020;
  padding: 8px;
}
#emulator-controls button {
  width: 2.5em;
  height: 2.5em;
  padding: 4px;
}
#emulator-controls button svg {
  width: 1.5em;
  height: 1.5em;
  fill: black;
}
#emulator-controls button:disabled svg {
  fill: gray;
}
#emulator-controls separator {
  display: inline-block;
  border-left: 3px inset gray;
  height: 2.5em;
  vertical-align: bottom;
}
</style>

## About

The black box below is an ANSI terminal emulator with an emulated *Ashet* connected to it. Just press `h` to see the available options in the boot rom.

Currently, the emulator runs the [serial BIOS](https://github.com/MasterQ32/spu-mark-ii/blob/master/apps/web-firmware/main.asm) of *Ashet*, as the graphical components are still in development.

<div id="live-terminal"></div>

<div id="emulator-controls">
    <button id="emulator-load" type="button" title="Load firmware" onclick="beginUserSelectFile()" disabled><svg viewBox="0 0 24 24">
    <path d="M19,20H4C2.89,20 2,19.1 2,18V6C2,4.89 2.89,4 4,4H10L12,6H19A2,2 0 0,1 21,8H21L4,8V18L6.14,10H23.21L20.93,18.5C20.7,19.37 19.92,20 19,20Z" />
</svg></button>
    <separator></separator>
    <button id="emulator-reset" type="button" title="Reset CPU" onclick="invokeReset()"><svg viewBox="0 0 24 24">
    <path d="M12,4C14.1,4 16.1,4.8 17.6,6.3C20.7,9.4 20.7,14.5 17.6,17.6C15.8,19.5 13.3,20.2 10.9,19.9L11.4,17.9C13.1,18.1 14.9,17.5 16.2,16.2C18.5,13.9 18.5,10.1 16.2,7.7C15.1,6.6 13.5,6 12,6V10.6L7,5.6L12,0.6V4M6.3,17.6C3.7,15 3.3,11 5.1,7.9L6.6,9.4C5.5,11.6 5.9,14.4 7.8,16.2C8.3,16.7 8.9,17.1 9.6,17.4L9,19.4C8,19 7.1,18.4 6.3,17.6Z" />
</svg></button>
    <button id="emulator-nmi" type="button" title="Trigger NMI" onclick="invokeNmi()"><svg viewBox="0 0 24 24">
    <path d="M10 3H14V14H10V3M10 21V17H14V21H10Z" />
</svg></button>
    <separator></separator>
    <button id="emulator-start" type="button" title="Start emulation"  onclick="startEmulation()" disabled><svg viewBox="0 0 24 24">
    <path d="M8,5.14V19.14L19,12.14L8,5.14Z" />
</svg></button>
    <button id="emulator-stop" type="button" title="Pause emulation" onclick="pauseEmulation()" ><svg viewBox="0 0 24 24">
    <path d="M14,19H18V5H14M6,19H10V5H6V19Z" />
</svg></button>
    <button id="emulator-step" type="button" title="Single-step" onclick="tickEmulation()"  disabled><svg viewBox="0 0 24 24">
    <path d="M5,5V19H8V5M10,5V19L21,12" />
</svg></button>
</div>

<p style="display: none">
  <input id="emulator-file-select" type="file">
</p>

<script type="text/javascript" src="livedemo.js"></script>

&nbsp;

## Quick start:

Pause the emulator, and load a binary file compiled with the assember. Then press the play button to run your program.

Programs can be compiled with the assembler like this:
```
./zig-out/bin/assembler --format binary --output application.bin application.asm
```

<!--
Focus the emulator terminal, press `h` to display a short help text from the BIOS. Then press `l` to go into [ihex](https://en.wikipedia.org/wiki/Intel_HEX) loading mode. The *BIOS* now awaits a valid ihex file over the serial port. Paste this text into the terminal:

```ihex
:1080000008011A8008050200081E06001800881DD5
:1080100000406C020E80180018020D48656C6C6FF1
:0A8020002C20576F726C64210000E1
:00000001FF
```

This has loaded a small *Hello World* program into RAM that can now be executed by pressing `g`.
-->

Now you know how to load your own programs, go write one! Starting point is [AN000](../app-notes/AN000 - Understanding the Instruction Set.md) and [AN001](../app-notes/AN001 - The SPU Assembly Language.md), as well as the [ISA description](../specs/spu-mark-ii.md).


## Memory Layout

The memory layout for the emulator is:

| Memory Range        | Function          |
|---------------------|-------------------|
| `0x0000`…`0x7FFD`   | BIOS ROM          |
| `0x7FFE`            | UART Port. Write to send blockingly, read nonblockingly. No value available returns 0xFFFF. |
| `0x8000`…`0xFFFF`   | RAM 1             |
