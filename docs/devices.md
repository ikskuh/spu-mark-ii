# SPU Mark II Hardware Documentation

## Overview
- I/O-Bus is I²C
- Each device only has a single address
- Each device has an interrupt

## Interrupt Controller
- Maps interrupt lanes to a single hardware interrupt
- Allows masking of hardware interrupts
- Stores device addresses that can be queries
- On interrupt of a device the device is beeing masked, 
  so it can't fire another interrupt

## LCD Display Device
- Write $value to $displayAddress
- Write $value to $characterAddress

## Keyboard Device
- Write:
		Set keyboard flags (3 LEDs, Repetition)
- Read:
		Read from scancode buffer
		ACK on success, NACK when empty (if possible)

## Keypad Device
- Read:
		Read number from input buffer
		ACK on success, NACK when empty.

## Serial Port Device
- 9600,8N1
- Read:  Read byte from buffer, (N)ACK for feedback
- Write: Write byte to port

## Mass Storage Device
- SD Card up to 4 GB

## RTC
- Real Time Clock
- 