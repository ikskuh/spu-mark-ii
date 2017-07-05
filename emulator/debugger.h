#pragma once

#include "emulator.h"
#include <spu-2.h>
#include <stdbool.h>

/**
 * Initializes the debugger
 */
void dbg_init();

/**
 * @brief Enters the debugging console
 *        When the debugger returns to normal execution,
 *        this function will return.
 */
void dbg_enter();

/**
 * @brief Force-quits a running debugger into continueing
 *        normal execution.
 */
void dbg_quit();

/**
 * @brief Ticks the debugger in the background and checks for
 *        breakpoints and similar.
 */
bool dbg_tick();