#include <stdio.h>
#include <fcntl.h>   /* File Control Definitions           */
#include <termios.h> /* POSIX Terminal Control Definitions */
#include <unistd.h>  /* UNIX Standard Definitions 	   */
#include <errno.h>   /* ERROR Number Definitions           */
#include <stdint.h>

uint8_t configure_serial(int fd)
{
  struct termios SerialPortSettings; /* Create the structure                          */

  tcgetattr(fd, &SerialPortSettings); /* Get the current attributes of the Serial port */

  /* Setting the Baud rate */
  cfsetispeed(&SerialPortSettings, B19200);
  cfsetospeed(&SerialPortSettings, B19200);

  /* 8N1 Mode */
  SerialPortSettings.c_cflag &= ~PARENB; /* Disables the Parity Enable bit(PARENB),So No Parity   */
  SerialPortSettings.c_cflag &= ~CSTOPB; /* CSTOPB = 2 Stop bits,here it is cleared so 1 Stop bit */
  SerialPortSettings.c_cflag &= ~CSIZE;  /* Clears the mask for setting the data size             */
  SerialPortSettings.c_cflag |= CS8;     /* Set the data bits = 8                                 */

  SerialPortSettings.c_cflag &= ~CRTSCTS;       /* No Hardware flow Control                         */
  SerialPortSettings.c_cflag |= CREAD | CLOCAL; /* Enable receiver,Ignore Modem Control lines       */

  SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);         /* Disable XON/XOFF flow control both i/p and o/p */
  SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG); /* Non Cannonical mode                            */

  SerialPortSettings.c_oflag &= ~OPOST; /*No Output Processing*/

  /* Setting Time outs */
  SerialPortSettings.c_cc[VMIN] = 1;  /* Read at least 10 characters */
  SerialPortSettings.c_cc[VTIME] = 0; /* Wait indefinetly   */

  int error = 0;
  if ((tcsetattr(fd, TCSANOW, &SerialPortSettings)) != 0) /* Set the attributes to the termios structure*/
    error = 1;

  tcflush(fd, TCIFLUSH); /* Discards old data in the rx buffer            */

  return error;
}

void flush_serial(int fd)
{
  tcflush(fd, TCIOFLUSH);
}