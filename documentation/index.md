## Introduction

The Ashet Home Computer, or short just *Ashet* is a late 80ies style inspired [home computer](https://en.wikipedia.org/wiki/Home_computer) with a 16 bit cpu.

Most components of *Ashet* are self-developed chips and computer components, like the *SPU Mark II* CPU, the yet unnamed MMU, video chip and blitter DMA.

## Goal of the project

The goal is to create a home computer around the *SPU Mark II* CPU that can be used for games, music and demos. The CPU is a quite novel approach on instruction set style as well as the attempt to create a CPU that is easily programmed by humans and compilers the like.

To overcome the 64k memory limitation own to 16 bit cpus is overcome by a paging unit providing 16 pages a 4096 byte that can be mapped to *any* page in a 16 MB large memory space. The I/O architecture is inspirted by the [Amiga 500](https://en.wikipedia.org/wiki/Amiga_500), like a DMA chip ("blitter") that allows trivial image/block transfers in memory as well as a graphics chip with sprite support. In contrast to the Amiga though the *Ashet* uses a 256 color linear framebuffer with a configurable palette of 16 bit colors, allowing the user to chose 256 of 65536 possible colors.

## State of the project

Right now, everything is work in progress and a lot of links on this site will be broken or the documents will be incomplete, but get filled in the future. If you want to support the project, [mail me](mailto:contact@ashet.computer)!

Most core components are either in *concept phase* or in *implementation phase*, some even near-completion

- Hardware
  - SPU Mark II (nearly complete, only missing 
  - UART serial port (nearly completion, misses only a good MMIO interface)
  - RAM interface (complete, RAM test works)
  - MMU (planning done, implementation is up next)
- Toolchain
  - Assembler (work-in-progress, misses some directives and expression evaluation)
  - Debugging iterface to the SOC
  - Emulator (mirrors the state of hardware, will be updated as soon as HW gains new features)