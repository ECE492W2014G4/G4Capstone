#include <semaphore.h>

typedef struct{
	unsigned char buffer[4096];
	long length;
} audio_buffer;

typedef struct{
	audio_queue * next;
	audio_buffer aud;
	audio_queue * prev;
} audio_queue;

