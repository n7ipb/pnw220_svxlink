#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
     
float temp;
void readTemp(void) {
  int fd = open("/sys/class/thermal/thermal_zone0/temp", O_RDONLY);
  if(fd == -1)
         {
          perror ("Couldn't open the temp device.");
                 return;
         }
  char buf[256];
  ssize_t numRead;
        read(fd, buf, 256);
	temp = atof(buf);
                 printf("%3.2f\n", (temp / 1000) * 9 / 5 + 32 );
         close(fd);
 return;
}

int main (void) {
  readTemp();
 return 0;
}
