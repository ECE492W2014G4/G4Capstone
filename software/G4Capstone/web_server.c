/******************************************************************************
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is          *
 * subject to the License Agreement located at the end of this file below.     *
 *******************************************************************************
 *                                                                             *
 * Modified to work with Interniche (week of 9/22/06) - BjR                    *
 *                                                                             *
 * This is an example webserver using NicheStack on the MicroC/OS-II RTOS.     *
 * It is in no way a complete implementation of a webserver, it is enough to   *
 * serve up our demo pages and control a few board elements and that's it.     *
 *                                                                             *
 * This example uses the sockets interface. A good introduction to sockets     *
 * programming is the book Unix Network Programming by Richard Stevens.        *
 *                                                                             *
 * Please refer to file ReadMe.txt for notes on this software example.         *
 ******************************************************************************
 * NicheStack TCP/IP stack initialization and Operating System Start in main()
 * for this example.
 *
 * This example demonstrates the use of MicroC/OS-II running on NIOS II.
 * In addition it is to serve as a good starting point for designs using
 * MicroC/OS-II and Altera NicheStack TCP/IP Stack - NIOS II Edition.
 *
 * Please refer to the Altera NicheStack Tutorial documentation for details on
 * this software example, as well as details on how to configure the NicheStack
 * TCP/IP networking stack and MicroC/OS-II Real-Time Operating System.
 */

/* MicroC/OS-II definitions */
#include "includes.h"

#include <stdio.h>
#include <errno.h>
#include <ctype.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_up_avalon_character_lcd.h"
#include <sys/alt_irq.h>
#include "altera_avalon_timer_regs.h"
#include "altera_up_avalon_audio_and_video_config.h"
#include <unistd.h>

/* Web Server definitions */
#include "alt_error_handler.h"
#include "web_server.h"

/* Nichestack definitions */
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "tcpport.h"
#include "net.h"
#include "dm9000a.h"


extern int current_flash_block;

extern void WSTask();
static void WSCreateTasks();
void AudioTask(void* pdata);
void LCDTask(void* pdata);

/* NicheStack network structure. */
extern struct net netstatic[STATIC_NETS];


/* Declarations for creating a task with TK_NEWTASK.  
 * All tasks which use NicheStack (those that use sockets) must be created this way.
 * TK_OBJECT macro creates the static task object used by NicheStack during operation.
 * TK_ENTRY macro corresponds to the entry point, or defined function name, of the task.
 * inet_taskinfo is the structure used by TK_NEWTASK to create the task.
 */

TK_OBJECT(to_wstask);
TK_ENTRY(WSTask);

struct inet_taskinfo wstask = {
		&to_wstask,
		"web server",
		WSTask,
		HTTP_PRIO,
		APP_STACK_SIZE,
};




/* WSInitialTask will initialize the NichStack TCP/IP stack and then initialize
 * the rest of the web server example tasks.
 */

void WSInitialTask(void* pdata)
{
	INT8U error_code = OS_NO_ERR;

	/*
	 * Initialize Altera NicheStack TCP/IP Stack - Nios II Edition specific code.
	 * NicheStack is initialized from a task, so that RTOS will have started, and
	 * I/O drivers are available.  Two tasks are created:
	 *    "Inet main"  task with priority 2
	 *    "clock tick" task with priority 3
	 */
	alt_iniche_init();
	/* Start the Iniche-specific network tasks and initialize the network
	 * devices.
	 */
	netmain();
	/* Wait for the network stack to be ready before proceeding. */
	while (!iniche_net_ready)
		TK_SLEEP(1);
	/* Create the main network task.  In this case, a web server. */
	TK_NEWTASK(&wstask);

	/* Application specific code starts here... */

	/*Create Tasks*/
	WSCreateTasks();
	printf("\nWeb Server starting up\n");
	/* Application specific code ends here. */
	/*This task deletes itself, since there's no reason to keep it around, once
	 *it's complete.
	 */
	error_code = OSTaskDel(OS_PRIO_SELF);
	alt_uCOSIIErrorHandler(error_code, 0);

	while(1); /*Correct Program Flow should not reach here.*/
}


/* Definition of Task Stacks for tasks not using networking.*/
OS_STK    WSInitialTaskStk[TASK_STACKSIZE];
OS_STK    AudioTask_stk[TASK_STACKSIZE];
OS_STK    LCDTask_stk[TASK_STACKSIZE];

OS_EVENT *board_control_mbox;
OS_EVENT *QUEUE;

int main (int argc, char* argv[], char* envp[])
{
	/* Initialize the current flash block, for flash programming. */
	DM9000A_INSTANCE( DM9000A_0, dm9000a_0 );
	DM9000A_INIT( DM9000A_0, dm9000a_0 );

	current_flash_block = -1;

	INT8U error_code;

	/* Clear the RTOS timer */
	OSTimeSet(0);

	/* WSInitialTask will initialize the NicheStack TCP/IP Stack and then
	 * initialize the rest of the web server's tasks.
	 */

	error_code = OSTaskCreateExt(WSInitialTask,
			NULL,
			(void *)&WSInitialTaskStk[TASK_STACKSIZE-1],
			WS_INITIAL_TASK_PRIO,
			WS_INITIAL_TASK_PRIO,
			WSInitialTaskStk,
			TASK_STACKSIZE,
			NULL,
			0);
	alt_uCOSIIErrorHandler(error_code, 0);


	/*
	 * As with all MicroC/OS-II designs, once the initial thread(s) and
	 * associated RTOS resources are declared, we start the RTOS. That's it!
	 */
	OSStart();

	while(1); /* Correct Program Flow never gets here. */

	return -1;
}


static void WSCreateTasks()
{
	INT8U error_code = OS_NO_ERR;
	alt_up_character_lcd_dev * lcd=alt_up_character_lcd_open_dev(CHARACTER_LCD_0_NAME);
	alt_up_character_lcd_init(lcd);
	int msg[1];

	QUEUE=OSQCreate(&msg, 1);
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

}

// Adapted from audio appnote by Group 11 - Sean Hunter, Michael Wong, Thomas Zylstra
//URL: https://www.ualberta.ca/~delliott/local/ece492/appnotes/2013w/audio_altera_university_ip_cores/
void AudioTask(void *pdata){
	alt_up_av_config_dev * audio_config_dev;

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

	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_SAMPLING_CTRL, 0x20);
	unsigned int *sw = (unsigned int *)PIO_0_BASE;
	while(1){
		printf("Switch state:%u\n",*sw);
		OSTimeDlyHMSM(0,0,1,0);
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
