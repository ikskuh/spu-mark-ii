#!/bin/bash

echo -e "\033[31;1mBuild!\033[0m"
make -C emulator
make -C assembler

echo -e "\033[31;1mAssemble!\033[0m"
./assembler/assembler "$1" > /tmp/code.hex || exit
cat /tmp/code.hex

echo -e "\033[31;1mRun!\033[0m"
cat /tmp/code.hex | ./emulator/simulator.exe || exit

echo -e "\033[31;1mDone!\033[0m"
