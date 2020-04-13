#include <stdbool.h> // stellt "true" bereit
#include <stddef.h>
#include <avr/io.h> // stellt DDRB, PORTB und PIN5 bereit
#include <avr/interrupt.h>
#include <util/delay.h> // stellt _delay_ms bereit
#include <stdio.h>
#include <string.h>

// UART_BAUD ist im Makefile definiert
#define UBRR_BAUD ((F_CPU / (16 * (UART_BAUD))) - 1)

#if (UBRR_BAUD & ~0xFFF) != 0
#error "Baud rate out of range!"
#endif

void uart_tx(char c)
{
  while ((UCSR0A & (1 << UDRE0)) == 0)
    ; // warte darauf, dass wir senden dürfen
  UDR0 = c;
}

#define PORT_OUT PORTD
#define PORT_IN PIND
#define PIN_RCV_CLK (1 << PIN2)
#define PIN_RCV_DAT (1 << PIN3)
#define PIN_TXD_CLK (1 << PIN4)
#define PIN_TXD_DAT (1 << PIN5)

int main()
{
  UCSR0A = 0;                             // Single Speed, Kein Multiprozessormodus
  UCSR0B = (1 << RXEN0) | (1 << TXEN0);   // Sender und Empfänger anschalten
  UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8N1
  UBRR0 = (UBRR_BAUD & 0xFFF);

  DDRD = (PIN_TXD_CLK | PIN_TXD_DAT);

  enum
  {
    RCV_WAIT_HIGH,
    RCV_WAIT_LOW,
  };

  uint8_t rcv_buf = 0;
  uint8_t rcv_off = 0;
  uint8_t rcv_state = RCV_WAIT_HIGH;

  while (true)
  {
    // when something was received, get it from the buffer
    if (UCSR0A & (1 << RXC0))
    {
      uint8_t chr = UDR0;
      uint8_t port_base = PORT_OUT & ~(PIN_TXD_DAT | PIN_TXD_CLK);
      uint8_t i = 128;
      while (i != 0)
      {
        if (chr & i)
          PORT_OUT = port_base | (PIN_TXD_DAT | PIN_TXD_CLK);
        else
          PORT_OUT = port_base | PIN_TXD_CLK;
        _delay_us(0.5);
        PORT_OUT = port_base;
        _delay_us(0.5);
        i >>= 1;
      }
    }

    switch (rcv_state)
    {
    case RCV_WAIT_HIGH:
    {
      if (PORT_IN & PIN_RCV_CLK)
      {
        if (PORT_IN & PIN_RCV_DAT)
          rcv_buf |= (1 << rcv_off);
        if (rcv_off == 7)
        {
          uart_tx(rcv_buf);
          rcv_off = 0;
          rcv_buf = 0;
        }
        else
        {
          rcv_off += 1;
        }
        rcv_state = RCV_WAIT_LOW;
      }
      break;
    }
    case RCV_WAIT_LOW:
    {
      if ((PORT_IN & PIN_RCV_CLK) == 0)
      {
        rcv_state = RCV_WAIT_HIGH;
      }
      break;
    }
    }
  }
}
