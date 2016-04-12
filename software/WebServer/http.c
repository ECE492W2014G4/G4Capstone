/******************************************************************************
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is          *
 * subject to the License Agreement located at the end of this file below.     *
 *******************************************************************************
 *                                                                             *
 * File: http.c                                                                *
 *                                                                             *
 * A rough imlementation of HTTP. This is not intended to be a complete        *
 * implementation, just enough for a demo simple web server. This example      *
 * application is more complex than the telnet serer example in that it uses   *
 * non-blocking IO & multiplexing to allow for multiple simultaneous HTTP      *
 * sessions.                                                                   *
 *                                                                             *
 * This example uses the sockets interface. A good introduction to sockets     *
 * programming is the book Unix Network Programming by Richard Stevens         *
 *                                                                             *
 * Please refer to file ReadMe.txt for notes on this software example.         *
 *******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/param.h>
#include <sys/fcntl.h>
#include "sys/alt_alarm.h"
#include "alt_types.h"
#include <unistd.h>
#include "web_server.h"
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "tcpport.h"


#ifdef DEBUG
#include alt_debug.h
#else
#define ALT_DEBUG_ASSERT(a)
#endif /* DEBUG */

#define MY_PORT 10000
#define BUFFER_SIZE 1024

int net_aton(const char *cp, struct in_addr *addr);

void WSTask(){
	int s;
	int suspended = 0;
	int counter = 0;
	long read,total;
	INT8U err;
	alt_u16 buff[BUFFER_SIZE];

	//Setup connection to server
	struct sockaddr_in result;
	memset(&result, 0, sizeof(struct sockaddr_in));
	result.sin_family = AF_INET;
	result.sin_port = htons(MY_PORT);
	net_aton("198.23.158.70", &(result.sin_addr));

	//Test the connection
	s = socket(AF_INET, SOCK_STREAM, 0);
	if (s < 0) {
		sendToLCD("Client: cannot open socket");
		die_with_error("");
	}
	if (connect(s, (struct sockaddr *) &result, sizeof(result))) {
		sendToLCD("No connection");
		die_with_error("");
	}
	close(s);

	while (1) {
		if (counter >= BUFFER_SIZE){
			s = socket(AF_INET, SOCK_STREAM, 0);
			if (s < 0) {
				sendToLCD("Client: cannot open socket");
				OSTaskDel(HTTP_PRIO);
			}
			if (connect(s, (struct sockaddr *) &result, sizeof(result))) {
				die_with_error("");
				OSTaskDel(HTTP_PRIO);
			}
			read = write(s,buff, counter);
			total += read;
			if( read < 0 ){
				sendToLCD("Lost connection");
				die_with_error("");
			}
			printf("Sent %d bytes to client. Total: %d\n", read, total);
			close(s);
			counter = 0;
		}
		int fill_level;
		while((fill_level = altera_avalon_fifo_read_level(INTERNET_FIFO_OUT_BASE)) > 0 && counter < BUFFER_SIZE){
			buff[counter] = (alt_u16) altera_avalon_fifo_read_fifo(INTERNET_FIFO_OUT_BASE,INTERNET_FIFO_IN_CSR_BASE);
			counter++;
		}
	}
}
/* from http://www.opensource.apple.com/source/OpenSSH/OpenSSH-7.1/openssh/bsd-inet_aton.c */
int net_aton(const char *cp, struct in_addr *addr)
{
	register alt_u32 val;
	register int base, n;
	register char c;
	unsigned int parts[4];
	register unsigned int *pp = parts;

	c = *cp;
	for (;;) {
		/*
		 * Collect number up to ``.''.
		 * Values are specified as for C:
		 * 0x=hex, 0=octal, isdigit=decimal.
		 */
		if (!isdigit(c))
			return (0);
		val = 0; base = 10;
		if (c == '0') {
			c = *++cp;
			if (c == 'x' || c == 'X')
				base = 16, c = *++cp;
			else
				base = 8;
		}
		for (;;) {
			if (isascii(c) && isdigit(c)) {
				val = (val * base) + (c - '0');
				c = *++cp;
			} else if (base == 16 && isascii(c) && isxdigit(c)) {
				val = (val << 4) |
						(c + 10 - (islower(c) ? 'a' : 'A'));
				c = *++cp;
			} else
				break;
		}
		if (c == '.') {
			/*
			 * Internet format:
			 *	a.b.c.d
			 *	a.b.c	(with c treated as 16 bits)
			 *	a.b	(with b treated as 24 bits)
			 */
			if (pp >= parts + 3)
				return (0);
			*pp++ = val;
			c = *++cp;
		} else
			break;
	}
	/*
	 * Check for trailing characters.
	 */
	if (c != '\0' && (!isascii(c) || !isspace(c)))
		return (0);
	/*
	 * Concoct the address according to
	 * the number of parts specified.
	 */
	n = pp - parts + 1;
	switch (n) {

	case 0:
		return (0);		/* initial nondigit */

	case 1:				/* a -- 32 bits */
		break;

	case 2:				/* a.b -- 8.24 bits */
		if ((val > 0xffffff) || (parts[0] > 0xff))
			return (0);
		val |= parts[0] << 24;
		break;

	case 3:				/* a.b.c -- 8.8.16 bits */
		if ((val > 0xffff) || (parts[0] > 0xff) || (parts[1] > 0xff))
			return (0);
		val |= (parts[0] << 24) | (parts[1] << 16);
		break;

	case 4:				/* a.b.c.d -- 8.8.8.8 bits */
		if ((val > 0xff) || (parts[0] > 0xff) || (parts[1] > 0xff) || (parts[2] > 0xff))
			return (0);
		val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
		break;
	}
	if (addr)
		addr->s_addr = htonl(val);
	return (1);
}

/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved.                                                        *
 *                                                                             *
 * Permission is hereby granted, free of charge, to any person obtaining a     *
 * copy of this software and associated documentation files (the "Software"),  *
 * to deal in the Software without restriction, including without limitation   *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
 * and/or sell copies of the Software, and to permit persons to whom the       *
 * Software is furnished to do so, subject to the following conditions:        *
 *                                                                             *
 * The above copyright notice and this permission notice shall be included in  *
 * all copies or substantial portions of the Software.                         *
 *                                                                             *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
 * DEALINGS IN THE SOFTWARE.                                                   *
 *                                                                             *
 * This agreement shall be governed in all respects by the laws of the State   *
 * of California and by the laws of the United States of America.              *
 * Altera does not recommend, suggest or require that this reference design    *
 * file be used in conjunction or combination with any other product.          *
 ******************************************************************************/
