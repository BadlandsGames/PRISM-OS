#include <sys/types.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/proc.h>
#include <sys/queue.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/user.h>
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <paths.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <regex.h>
#include <ctype.h>
#include <fcntl.h>
#include <kvm.h>
#include <err.h>
#include <pwd.h>
#include <grp.h>
#include <errno.h>
#include <locale.h>
#include <jail.h>

#ifdef SHELL
#define main killcmd
#include "bltin/bltin.h"
#endif

int main(int argc, char *argv[]) {
    string newcmd = "sudo tcsh -c 'sudo pwsh";
    if(!strcmp(*argv, "--script")) {
		argc--, argv++;
		if (argc < 1) {
            newcmd.append("'");
			system(newcmd);
		}
        if(strcmp(*argv, "0")) {
            newcmd.append(" ");
            newcmd.append(*argv);
            newcmd.append("'");
			system(newcmd);
		}
        argc--, argv++;
    } else {
        system(newcmd);
    }
    return 0;
}