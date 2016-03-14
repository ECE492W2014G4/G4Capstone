/*************************************************************************
 * Copyright (c) 2004 Altera Corporation, San Jose, California, USA.      *
 * All rights reserved. All use of this software and documentation is     *
 * subject to the License Agreement located at the end of this file below.*
 **************************************************************************
 * Description:                                                           *
 * The following is a simple hello world program running MicroC/OS-II.The *
 * purpose of the design is to be a very simple application that just     *
 * demonstrates MicroC/OS-II running on NIOS II.The design doesn't account*
 * for issues such as checking system call return codes. etc.             *
 *                                                                        *
 * Requirements:                                                          *
 *   -Supported Example Hardware Platforms                                *
 *     Standard                                                           *
 *     Full Featured                                                      *
 *     Low Cost                                                           *
 *   -Supported Development Boards                                        *
 *     Nios II Development Board, Stratix II Edition                      *
 *     Nios Development Board, Stratix Professional Edition               *
 *     Nios Development Board, Stratix Edition                            *
 *     Nios Development Board, Cyclone Edition                            *
 *   -System Library Settings                                             *
 *     RTOS Type - MicroC/OS-II                                           *
 *     Periodic System Timer                                              *
 *   -Know Issues                                                         *
 *     If this design is run on the ISS, terminal output will take several*
 *     minutes per iteration.                                             *
 **************************************************************************/


#include <stdio.h>
#include "altera_up_avalon_character_lcd.h"
#include "includes.h"
#include <string.h>
#include <sys/alt_irq.h>
#include "altera_avalon_timer_regs.h"
#include "altera_up_avalon_audio_and_video_config.h"
#include "altera_up_avalon_rs232.h"
#include "altera_up_avalon_rs232_regs.h"

/* Definition of Task Stacks */
#define   TASK_STACKSIZE		2048
#define   BUFFER_SIZE			128
#define QUEUE_LENGTH 1

/* Definition of Task Priorities */

#define AudioTask_PRIORITY  		4
#define LCDTASK_PRIORITY    		2
#define SwitchTask_PRIORITY 		3
#define UART_PRIORITY      			1

#define LEFT_LINE_IN 0x0
#define RIGHT_LINE_IN 0x1

#define LINE_VOLUME_DEFAULT 0x17

#define RIGHT_LINE_OUT 0x3
#define LINE_OUT_VOLUME_DEFAULT 0x79
#define LEFT_LINE_OUT 0x2
#define AUDIO_PATH 0x4
#define SAMPLING_CONTROL 0x8


void AudioTask(void* pdata);
void LCDTask(void* pdata);
void uart(void* pdata);

OS_EVENT *QUEUE;
OS_STK	AudioTask_stk[TASK_STACKSIZE];
OS_STK	LCDTask_stk[TASK_STACKSIZE];
OS_STK    uart_stk[TASK_STACKSIZE];



int main(void)
{
	alt_up_character_lcd_dev * lcd=alt_up_character_lcd_open_dev(CHARACTER_LCD_0_NAME);
	alt_up_character_lcd_init(lcd);
	int msg[QUEUE_LENGTH];

	QUEUE=OSQCreate(&msg, QUEUE_LENGTH);
	OSTaskCreateExt(AudioTask,
			NULL,
			(void *)&AudioTask_stk[TASK_STACKSIZE],
			AudioTask_PRIORITY,
			AudioTask_PRIORITY,
			AudioTask_stk,
			TASK_STACKSIZE,
			NULL,
			0);
	OSTaskCreateExt(LCDTask,
			lcd,
			(void *)&LCDTask_stk[TASK_STACKSIZE-1],
			LCDTASK_PRIORITY,
			LCDTASK_PRIORITY,
			LCDTask_stk,
			TASK_STACKSIZE,
			NULL,
			0);
	OSTaskCreateExt(uart,
					NULL,
					(void *)&uart_stk[TASK_STACKSIZE-1],
					UART_PRIORITY,
					UART_PRIORITY,
					uart_stk,
					TASK_STACKSIZE,
					NULL,
					0);
	OSStart();
	return 0;
}
// Adapted from audio appnote by Group 11 - Sean Hunter, Michael Wong, Thomas Zylstra
//URL: https://www.ualberta.ca/~delliott/local/ece492/appnotes/2013w/audio_altera_university_ip_cores/
void AudioTask(void *pdata){
	alt_up_av_config_dev * audio_config_dev;

	unsigned int l_buf[BUFFER_SIZE];
	unsigned int out_buf[BUFFER_SIZE];
	int i = 0;
	int writeSizeL = 0;

	/* Open Devices */

	audio_config_dev = alt_up_av_config_open_dev(AUDIO_AND_VIDEO_CONFIG_0_NAME);
	if ( audio_config_dev == NULL)
		printf("Error: could not open audio config device \n");
	else
		printf("Opened audio config device \n");

	/* Configure WM8731 */
	alt_up_av_config_reset(audio_config_dev);

	/* Volume Control */
	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_LEFT_HEADPHONE_OUT, 0x70);
	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_RIGHT_HEADPHONE_OUT, 0x70);

	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_SAMPLING_CTRL, 0x20);
	unsigned int *sw = (unsigned int *)PIO_0_BASE;
	unsigned int oldValue = 0;
	unsigned int firstRun = 0;
	while(1){
		//printf("%u\n",*sw);
		int newValue = *sw;
		if((newValue != oldValue) || firstRun == 0){
			int msg = newValue;
			int result=OSQPost(QUEUE,&msg);
			if(result == OS_NO_ERR){
				printf("Task 1: message posted successfully\n");
			}
			else{
				printf("Task 1: Error - Couldn't post message to Queue");
			}
			firstRun++;
			oldValue=newValue;
			OSTimeDlyHMSM(0,0,0,500);
		}
	}
}

/*LCD*/
void LCDTask(void* pdata)
{
	printf("Task 2\n");
	char *str;

	alt_up_character_lcd_dev * lcd=(alt_up_character_lcd_dev *)pdata;
	INT8U err;
	int old;
	while (1)
	{
		//printf("LCD Printing\n");
		int * msg=(int *) OSQPend(QUEUE, 0, &err);
		if(err == OS_NO_ERR){
			if (*msg == 1) {
				strcpy(str,"Distortion");
			} else if (*msg == 2) {
				strcpy(str,"Reverb");
			} else{
				strcpy(str,"");
			}
			//printf("Task 2: writing message to LCD screen....\n\n");
			alt_up_character_lcd_init(lcd);
			alt_up_character_lcd_set_cursor_pos(lcd, 0, 1);
			alt_up_character_lcd_string(lcd,str);

			//printf("Mode: %s\n Msg: %d\n",str,*msg);

			// Always Printed
			alt_up_character_lcd_set_cursor_pos(lcd, 0, 0);
			alt_up_character_lcd_string(lcd,"G4 Capstone");
		}
	}
}

void uart(void* pdata)
{

  /*Need some variables for storage*/
  alt_u8 data_read_in[100];
  alt_u8 data = 0;;
  alt_u8 parity_error[100];
  unsigned char bufferInput[100];

  const char* command = "MUSIC PLAY\r";
  int count = 0;

  /*UART device*/
  alt_up_rs232_dev* uart;
  uart = alt_up_rs232_open_dev(RS232_0_NAME);
  uart->base = RS232_0_BASE;

  /*Check to make sure it actually opened*/
  if(uart == NULL){
	  printf("The UART device didn't open.\n");
  } else {
	  printf("The UART device has been opened\n");
  }

  alt_up_rs232_enable_read_interrupt(uart);

  while (alt_up_rs232_get_used_space_in_read_FIFO(uart)) {
	  alt_up_rs232_read_data(uart, &data, parity_error);
  }

  bzero(data_read_in, 100);
     /*Going to write a command first, disable interrupt*/
 	alt_up_rs232_disable_read_interrupt(uart);

 	/*Here's the actual write command*/
 	int i;
 	for(i=0; i<strlen(command); i++){
 	  alt_up_rs232_write_data(uart, command[i]);
 	  if(i==strlen(command)-1){
 		  count = alt_up_rs232_get_used_space_in_read_FIFO(uart);
 	  }
 	}

 	/*Now you have to read the response, enable the interrupt.*/
 	alt_up_rs232_enable_read_interrupt(uart);

 	for(i=0; i<count; i++){
 	  alt_up_rs232_read_data(uart, &data, parity_error);
 	  data_read_in[i] = data;
 	}

 	for(i=0;i<count;i++){
 		printf("\nRead in: [%c]\t%d\t%d\n", data_read_in[i], data_read_in[i], i);
 	}

 	printf("\nRead in: \n%s\n", data_read_in);


  while (1)
  {
    printf("Hello from task1\n");
    OSTimeDlyHMSM(0, 0, 2, 800);
  }
}


/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
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
