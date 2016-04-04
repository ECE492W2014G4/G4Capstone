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
 MicroC/OS-II definitions */

#include "includes.h"
#include <stdio.h>
#include <errno.h>
#include <ctype.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
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


#define LCD_DISPLAY_NAME CHARACTER_LCD_0_NAME
#define QUEUE_LENGTH 1

extern int current_flash_block;

extern void WSTask();
static void my_isr(void* context);
static void gain_iisr(void* context);
static void gain_disr(void* context);
static void WSCreateTasks();
static void setupSound();
static void setupFifo();

void AudioTask(void* pdata);
void LevelTask(void* pdata);
void LCDTask(void* pdata);
void sendToLCD(const char* msg);
void uart(void* pdata);

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
void sendToLCD(const char* msg){
	alt_up_character_lcd_dev * lcd=alt_up_character_lcd_open_dev(CHARACTER_LCD_0_NAME);
	alt_up_character_lcd_init(lcd);
	alt_up_character_lcd_set_cursor_pos(lcd, 0, 0);
	alt_up_character_lcd_string(lcd, msg);
}

void WSInitialTask(void* pdata)
{
	INT8U error_code = OS_NO_ERR;
	setupSound();
	setupFifo();
	/*
	 * Initialize Altera NicheStack TCP/IP Stack - Nios II Edition specific code.
	 * NicheStack is initialized from a task, so that RTOS will have started, and
	 * I/O drivers are available.  Two tasks are created:
	 *    "Inet main"  task with priority 2
	 *    "clock tick" task with priority 3
//	 */
//	alt_iniche_init();
//	netmain();
//	int failed = 0;
//	while (!iniche_net_ready){
//		sendToLCD("Loading.....");
//		OSTimeDlyHMSM(0,0,10,0);
//		if(!iniche_net_ready){
//			failed = 1;
//			break;
//		}
//	}
//	if(!failed){
//		TK_NEWTASK(&wstask);
//	}
//	else{
//		sendToLCD("Failed to load ethernet");
//	}
	WSCreateTasks();
	/*This task deletes itself, since there's no reason to keep it around, once
	 *it's complete.
	 */
	error_code = OSTaskDel(OS_PRIO_SELF);
	alt_uCOSIIErrorHandler(error_code, 0);


	while(1); /*Correct Program Flow should not reach here.*/
}
/*
 * A MicroC/OS-II message box will be used to communicate between telnet
 * and bo
void board_control_task(void *pdata);

Definition of Task Stacks for tasks not using networking.*/

OS_EVENT *QUEUE;
OS_EVENT *LEVEL;
OS_STK	AudioTask_stk[TASK_STACKSIZE];
OS_STK	LevelTask_stk[TASK_STACKSIZE];
OS_STK	LCDTask_stk[TASK_STACKSIZE];
OS_STK    uart_stk[TASK_STACKSIZE];
OS_STK    WSInitialTaskStk[TASK_STACKSIZE];

int vol;

int main (int argc, char* argv[], char* envp[])
{
	/* Initialize the current flash block, for flash programming. */

	current_flash_block = -1;

	DM9000A_INSTANCE( DM9000A_0, dm9000a_0 );
	DM9000A_INIT( DM9000A_0, dm9000a_0 );


	INT8U error_code;

	/* Clear the RTOS timer */
	OSTimeSet(0);

	int msg[QUEUE_LENGTH];
	int vol[QUEUE_LENGTH];

	QUEUE=OSQCreate(&msg, QUEUE_LENGTH);
	LEVEL=OSQCreate(&vol, QUEUE_LENGTH);


	//IOWR_ALTERA_AVALON_TIMER_CONTROL(TUNER_TIMER_BASE, 0x7);
	//alt_ic_isr_register(TUNER_TIMER_IRQ_INTERRUPT_CONTROLLER_ID,TUNER_TIMER_IRQ,my_isr,NULL,NULL);
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(GAIN_INC_BASE, 0x1);
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(GAIN_INC_BASE, 0x0);
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(GAIN_DEC_BASE, 0x1);
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(GAIN_DEC_BASE, 0x0);

    alt_irq_register(GAIN_INC_IRQ,NULL,gain_iisr);
    alt_irq_register(GAIN_DEC_IRQ,NULL,gain_disr);
//	alt_ic_isr_register(GAIN_INC_IRQ_INTERRUPT_CONTROLLER_ID,GAIN_INC_IRQ,gain_iisr,NULL,NULL);
//	alt_ic_isr_register(GAIN_DEC_IRQ_INTERRUPT_CONTROLLER_ID,GAIN_DEC_IRQ,gain_disr,NULL,NULL);
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
void setupFifo(){
	altera_avalon_fifo_init(INTERNET_FIFO_IN_CSR_BASE,0x0,1,INTERNET_FIFO_OUT_FIFO_DEPTH-1);
}
void setupSound(){
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

	/* Volume Control */
	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_LEFT_HEADPHONE_OUT, 0x70);
	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_RIGHT_HEADPHONE_OUT, 0x70);
	alt_up_av_config_write_audio_cfg_register(audio_config_dev, AUDIO_REG_SAMPLING_CTRL, 0x20);
}

void WSCreateTasks(){
	alt_up_character_lcd_dev * lcd=alt_up_character_lcd_open_dev(CHARACTER_LCD_0_NAME);
	alt_up_character_lcd_init(lcd);
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
	OSTaskCreateExt(LevelTask,
				NULL,
				(void *)&LevelTask_stk[TASK_STACKSIZE-1],
				LevelTask_PRIORITY,
				LevelTask_PRIORITY,
				LevelTask_stk,
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
	OSTaskSuspend(UART_PRIORITY);
	//OSTaskSuspend(AudioTask_PRIORITY);
	//OSTaskSuspend(LCDTASK_PRIORITY);
}

void AudioTask(void *pdata){
	int *sw = (int *)PIO_0_BASE;
	unsigned int oldValue = 0;
	unsigned int firstRun = 0;
	while(1){
		int newValue = *sw;
		if((newValue != oldValue) || firstRun == 0 || newValue >= 3){
			int msg = newValue;
			int result=OSQPost(QUEUE,&msg);
			firstRun++;
			oldValue = newValue;
		}
		OSTimeDlyHMSM(0,0,0,100);
	}
}

void LevelTask(void* pdata){
	INT8U err;
	alt_u16 *distort = (alt_u16 *)DSP_0_CLIPPING_BASE; // Writing to
	alt_u16 *test = (alt_u16 *)DSP_0_CLIPPING_TEST_BASE; // Reading from
	alt_u16 counter = 6;
	while(1){
		int * msg = (int *) OSQPend(LEVEL, 0, &err);
		int level = *msg;
		if(level == 1){
			if(counter < 10){
				counter++;
			}
		}
		else if(level == -1){
			if(counter > 1){
				counter --;
			}
		}
		printf("Vol: %d, ", counter);
		*distort = counter;
		printf("DSP Vol: %u\n",*test);
	}
}

/*LCD*/
void LCDTask(void* pdata)
{
	char *str;
	alt_up_character_lcd_dev * lcd=(alt_up_character_lcd_dev *)pdata;
	INT8U err;
	int old;
	while (1)
	{
		//printf("LCD Printing\n");
		int * msg=(int *) OSQPend(QUEUE, 0, &err);
		if(err == OS_NO_ERR){
			if ((*msg) == 1) {
				strcpy(str,"Distortion");
			} else if ((*msg) == 2) {
				strcpy(str,"Reverb");
			} else if((*msg) == 4){
				char buffer[50];
				//int val = *(int *)DSP_0_BASE;
				//snprintf(buffer, 50,"Freq: %d",val);
				strcpy(str,buffer);
			}
			else{
				strcpy(str, "");
			}
			alt_up_character_lcd_init(lcd);
			alt_up_character_lcd_set_cursor_pos(lcd, 0, 1);
			alt_up_character_lcd_string(lcd,str);

			// Always Printed
			alt_up_character_lcd_set_cursor_pos(lcd, 0, 0);
			alt_up_character_lcd_string(lcd,"G4 Capstone");
		}
	}
}

static void my_isr(void* context)
{
	//OSQPost(QUEUE,(int *)DSP_0_BASE);
	//IOWR_ALTERA_AVALON_TIMER_STATUS(TUNER_TIMER_BASE, 0xFE);

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
void gain_iisr(void* context){
	vol = 1;
	OSQPost(LEVEL,&vol);
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(GAIN_INC_BASE, 0);
}
void gain_disr(void* context){
	vol = -1;
	OSQPost(LEVEL,&vol);
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(GAIN_DEC_BASE, 0);
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
