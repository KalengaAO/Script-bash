#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    pid_t pid = fork();

    if (pid > 0)
        sleep(60);
	else if (pid == 0)
        exit(0);
    else
        perror("fork falhou");
     return 0;
}

