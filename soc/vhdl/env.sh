#!/bin/bash
#setup all the environment variable required by Diamond and related executable files
#version 1.6

ROOT_PATH="/usr/local/diamond/3.11_x64"

FPGADIR="${ROOT_PATH}/bin/lin64"

export "FOUNDRY=${ROOT_PATH}/ispfpga/bin/lin64/"

export "PATH=${FOUNDRY}:${FPGADIR}:$PATH"
LD_LIBRARY_PATH="${FOUNDRY}:${FPGADIR}:${LD_LIBRARY_PATH}"

unset LSC_INI_PATH

#setup LSC_DIAMOND
export LSC_DIAMOND=true

#fix RH7 incompatible Qt library issue
export QT_PLUGIN_PATH=

#set the output max line width
export NEOCAD_MAXLINEWIDTH=32767

#setup tcl library
TCL_LIBRARY="${ROOT_PATH}/tcltk/lib/tcl8.5"
export TCL_LIBRARY
