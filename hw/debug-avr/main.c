#include <stdbool.h> // stellt "true" bereit
#include <stddef.h>
#include <avr/io.h> // stellt DDRB, PORTB und PIN5 bereit
#include <avr/interrupt.h>
#include <util/delay.h> // stellt _delay_ms bereit
#include <stdio.h>
#include <string.h>

#define TIMER1_FREQ 30 // Hz
#define TIMER1_PRESC 64
#define TIMER1_LIMIT (((F_CPU) / (TIMER1_PRESC)) / (TIMER1_FREQ)-1)

#if (TIMER1_LIMIT <= 0) || (TIMER1_LIMIT >= 65536)
#error "TIMER1 config is invalid!"
#endif

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
#define PIN_MOSI_CLK (1 << PD2) // INT0
#define PIN_MOSI_DAT (1 << PD3) // INT1
#define PIN_MISO_CLK (1 << PD4)
#define PIN_MISO_DAT (1 << PD5)

static void toggle_led()
{
  PORTB ^= (1 << PB5);
}

uint8_t rcv_buf = 0;
uint8_t rcv_off = 0;

ISR(INT0_vect)
{
  rcv_buf <<= 1;
  if ((PORT_IN & PIN_MOSI_DAT) != 0)
    rcv_buf |= 1;

  if (rcv_off == 7)
  {
    uart_tx(rcv_buf);
    rcv_off = 0;

    // reset not necessary as we shift 8 bit anyways
    // rcv_buf = 0x00;

    // reset timer
    TCNT1H = 0;
    TCNT1L = 0;
  }
  else
  {
    rcv_off += 1;
  }
}

ISR(TIMER1_COMPA_vect)
{
  // uart_tx('T');
  rcv_buf = 0;
  rcv_off = 0;
}

int main()
{
  UCSR0A = 0;
  UCSR0B = 0;
  UCSR0C = 0;
  while (true)
    ;
  UCSR0A = 0;                             // Single Speed, Kein Multiprozessormodus
  UCSR0B = (1 << RXEN0) | (1 << TXEN0);   // Sender und Empfänger anschalten
  UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8N1
  UBRR0 = (UBRR_BAUD & 0xFFF);

  DDRD = (PIN_MISO_CLK | PIN_MISO_DAT);
  DDRB = (1 << PB5);

  EICRA = (1 << ISC01) | (1 << ISC00); // The rising edge of INT0 generates an interrupt request.
  EIMSK = (1 << INT0);                 // External Interrupt Request 0 Enable

  // Setup des Timers
  TCCR1A = 0;                                        // Keine PWM-Generation
  TCCR1B = (1 << CS11) | (1 << CS10) | (1 << WGM12); // Prescaler=64,  CTC-Mode, TOP=OCR1A
  TCCR1C = 0;

  // Set the limit of the counter
  OCR1AH = (TIMER1_LIMIT >> 8) & 0xFF;
  OCR1AL = (TIMER1_LIMIT & 0xFF);

  TIMSK1 = (1 << OCIE1A); // Interrupt on compare match A

  sei(); // Interrupts an, hier beginnt es dann zu blinken

  while (true)
  {
    // when something was received, get it from the buffer
    if (UCSR0A & (1 << RXC0))
    {
      uint8_t chr = UDR0;
      uint8_t i = 128;
      while (i != 0)
      {
        if (chr & i)
          PORT_OUT = (PIN_MISO_DAT | PIN_MISO_CLK);
        else
          PORT_OUT = PIN_MISO_CLK;
        _delay_us(0.5);
        PORT_OUT = 0;
        _delay_us(0.5);
        i >>= 1;
      }
    }
  }
}
