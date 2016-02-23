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
#include <sys/alt_irq.h>
#include "altera_avalon_timer_regs.h"
#include "altera_up_avalon_audio_and_video_config.h"
#include "altera_up_avalon_audio.h"

/* Definition of Task Stacks */
#define   TASK_STACKSIZE		2048
#define   BUFFER_SIZE			128
#define QUEUE_LENGTH 1

/* Definition of Task Priorities */

#define AudioTask_PRIORITY      1
#define LCDTASK_PRIORITY      2

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

OS_EVENT *QUEUE;
OS_STK    AudioTask_stk[TASK_STACKSIZE];
OS_STK    LCDTask_stk[TASK_STACKSIZE];



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
	OSStart();
	return 0;
}
// Adapter from audio appnote by Group 11 - Sean Hunter, Michael Wong, Thomas Zylstra
//URL: https://www.ualberta.ca/~delliott/local/ece492/appnotes/2013w/audio_altera_university_ip_cores/
void AudioTask(void *pdata){
	 alt_up_audio_dev * audio_dev;
	    alt_up_av_config_dev * audio_config_dev;

	    unsigned int l_buf[BUFFER_SIZE];
	    int i = 0;
	    int writeSizeL = 0;

	    /* Open Devices */
	    audio_dev = alt_up_audio_open_dev (AUDIO_0_NAME);
	    if ( audio_dev == NULL)
	        printf("Error: could not open audio device \n");
	    else
	        printf("Opened audio device \n");

	    audio_config_dev = alt_up_av_config_open_dev(AUDIO_AND_VIDEO_CONFIG_0_NAME);
	    if ( audio_config_dev == NULL)
	        printf("Error: could not open audio config device \n");
	    else
	        printf("Opened audio config device \n");

	    /* Configure WM8731 */
	    alt_up_audio_reset_audio_core(audio_dev);
	    alt_up_av_config_reset(audio_config_dev);

	    alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_SAMPLING_CTRL, 0x20);

	    unsigned int status=0;
	    //main loop
	    while(1)
	    {
	            //read the data from the left buffer
	            writeSizeL = alt_up_audio_read_fifo(audio_dev, l_buf, BUFFER_SIZE, ALT_UP_AUDIO_LEFT);

	            //write data to the L and R buffers; R buffer will receive a copy of L buffer data
	            alt_up_audio_write_fifo (audio_dev, l_buf, writeSizeL, ALT_UP_AUDIO_RIGHT);
	            alt_up_audio_write_fifo (audio_dev, l_buf, writeSizeL, ALT_UP_AUDIO_LEFT);

	    }


}

/*LCD*/
void LCDTask(void* pdata)
{
	printf("Task 2");
	alt_up_character_lcd_dev * lcd=(alt_up_character_lcd_dev *)pdata;
	INT8U err;
	int old;
	while (1)
	{
		int * msg=(int *) OSQPend(QUEUE, 0, &err);
		if(err == OS_NO_ERR){
			alt_up_character_lcd_init(lcd);
			alt_up_character_lcd_set_cursor_pos(lcd, 0, 0);
			alt_up_character_lcd_string(lcd,"Hello World");
			OSQFlush(QUEUE);
			old=*msg;
		}
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
