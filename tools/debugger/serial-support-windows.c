#include <windows.h>
#include <stdint.h>

uint8_t configure_serial_windows(HANDLE hComm)
{
  DCB dcbSerialParams = {0}; // Initializing DCB structure
  dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

  if (GetCommState(hComm, &dcbSerialParams) == FALSE)
    return 1;

  dcbSerialParams.BaudRate = CBR_19200;
  dcbSerialParams.ByteSize = 8;
  dcbSerialParams.StopBits = ONESTOPBIT;
  dcbSerialParams.Parity = NOPARITY;

  if (SetCommState(hComm, &dcbSerialParams) == FALSE)
    return 1;

  COMMTIMEOUTS timeouts = {0};
  timeouts.ReadIntervalTimeout = 0;         // in milliseconds
  timeouts.ReadTotalTimeoutConstant = 0;    // in milliseconds
  timeouts.ReadTotalTimeoutMultiplier = 0;  // in milliseconds
  timeouts.WriteTotalTimeoutConstant = 0;   // in milliseconds
  timeouts.WriteTotalTimeoutMultiplier = 0; // in milliseconds
  if (SetCommTimeouts(hComm, &timeouts) == FALSE)
    return 1;

  return 0;
}

void flush_serial_windows(HANDLE hComm)
{
  PurgeComm(hComm, PURGE_RXCLEAR | PURGE_TXCLEAR);
}