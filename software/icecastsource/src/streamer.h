#include <semaphore.h>

typedef struct{
	unsigned char buffer[4096];
	long length;
} audio_buffer;

typedef struct {
	LIST_ENTRY(audio_buffer) list;
} audio_list; 

