' Author: Beau Schwabe
{{
    Once the `spi.Start` command is called from Spin, it will remain running in its own COG.
    If the Receive or Send command are called with 'Bits' set to Zero, then the COG will shut
    down.  Another way to shut the COG down is to call the 'spi.stop' command from Spin.
}}

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ

    term : "com.serial.terminal"
    num  : "string.integer"

CON

PUB Main
    term.StartRxTx(31, 30, 0, 115200) 
    dira[16..23] := 1
    outa[16..24] := $A5

    repeat
        term.Str(string("Hello, World", $0D, $0A))

        waitcnt(cnt + clkfreq * 100/1000)                        '' Pause for 10ms

PUB High(Pin)

    dira[Pin]~~
    outa[Pin]~~

PUB Low(Pin)

    dira[Pin]~~
    outa[Pin]~


