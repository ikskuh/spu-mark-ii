#pragma once

#define VT_CLS              "\033[2J"
#define VT_HOME             "\033[H"
#define VT_SETPOS(x,y)      "\033[" #x ";" #y "H"

#define VT_RESET            "\033c"
#define VT_ENABLE_LINEWRAP  "\033[7j"
#define VT_DISABLE_LINEWRAP "\033[7l"

#define VT_CUR_UP           "\033[A"
#define VT_CUR_DOWN         "\033[B"
#define VT_CUR_LEFT         "\033[D"
#define VT_CUR_RIGHT        "\033[C"
#define VT_CUR_SAVE         "\033[s"
#define VT_CUR_RESTORE      "\033[u"