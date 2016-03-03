/* example.c: Demonstration of the libshout API.
 * $Id$
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <shout/shout.h>
#include "streamer.h"

shout_t * setupShoutSource();
void *broadcastSource(void * param);
void *getAudio(void * param);

audio_buffer *buffer;

int main() {
	shout_t *shout = setupShoutSource();
	buffer = malloc(sizeof(audio_buffer));

	if (shout != NULL && shout_open(shout) == SHOUTERR_SUCCESS) {
		pthread_t tid[2];
		pthread_create(&tid[0], NULL, broadcastSource,(void *)shout);
		pthread_create(&tid[1], NULL, getAudio,NULL);
		int i=0;
		for(i=0; i<2; i++){
			pthread_join(tid[i],NULL);
		}
	}
	else if(shout == NULL){
		printf("Couldn't initiliaze icecast source");	
		return 1;
	} 
	else {
		printf("Error connecting: %s\n", shout_get_error(shout));
	}

	shout_close(shout);

	shout_shutdown();

	return 0;
}

void * getAudio(void * param){

}
void *broadcastSource(void * param){
	shout_t *shout = (shout_t *)param;
	unsigned char buff[4096];
	long read, ret, total;
	printf("Connected to server...\n");
		total = 0;
		FILE * song = fopen("/home/byron/test.ogg","r");
		if(song == NULL) perror("Couldn't open audio file\n");
		while (song != NULL) {
			read = fread(buff, 1, sizeof(buff), song);
			total = total + read;

			if (read > 0) {
				ret = shout_send(shout, buff, read);
				if (ret != SHOUTERR_SUCCESS) {
					printf("DEBUG: Send error: %s\n", shout_get_error(shout));
					break;
				}
			} else {
				break;
			}

			shout_sync(shout);
		}
}
shout_t * setupShoutSource(){
	shout_t *shout;
	shout_init();

	if (!(shout = shout_new())) {
		printf("Could not allocate shout_t\n");
		return NULL;
	}

	if (shout_set_host(shout, "127.0.0.1") != SHOUTERR_SUCCESS) {
		printf("Error setting hostname: %s\n", shout_get_error(shout));
		return NULL;
	}

	if (shout_set_protocol(shout, SHOUT_PROTOCOL_HTTP) != SHOUTERR_SUCCESS) {
		printf("Error setting protocol: %s\n", shout_get_error(shout));
		return NULL;
	}

	if (shout_set_port(shout, 8000) != SHOUTERR_SUCCESS) {
		printf("Error setting port: %s\n", shout_get_error(shout));
		return NULL;
	}

	if (shout_set_password(shout, "cubans") != SHOUTERR_SUCCESS) {
		printf("Error setting password: %s\n", shout_get_error(shout));
		return NULL;
	}
	if (shout_set_mount(shout, "/guitar.ogg") != SHOUTERR_SUCCESS) {
		printf("Error setting mount: %s\n", shout_get_error(shout));
		return NULL;
	}

	if (shout_set_user(shout, "source") != SHOUTERR_SUCCESS) {
		printf("Error setting user: %s\n", shout_get_error(shout));
		return NULL;
	}

	if (shout_set_format(shout, SHOUT_FORMAT_OGG) != SHOUTERR_SUCCESS) {
		printf("Error setting user: %s\n", shout_get_error(shout));
		return NULL;
	}
	return shout;
}
