#pragma once
#include <avr/io.h>
#include <stdint.h>

#define DDR_SPI DDRB
#define DD_SS   PB4
#define DD_MOSI PB5
#define DD_MISO PB6
#define DD_SCK  PB7

#define DD_MASK ((1<<DD_SS)|(1<<DD_MOSI)|(1<<DD_MISO)|(1<<DD_SCK))

void spi_initMaster(void);

void spi_initSlave(void);

uint8_t spi_xmit(uint8_t data);

void spi_send(uint8_t data);
uint8_t spi_receive();