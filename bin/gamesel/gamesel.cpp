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

#include <iostream>
using namespace std;

extern void run_psmapp(string filename_in);

#ifndef __USE_INDEX_ELF__
#include "index.h"
#endif

#ifdef SHELL
#define main killcmd
#include "bltin/bltin.h"
#endif

#define __USE_INDEX_ELF__

extern void main_py(void);

int main(int argc, char *argv[]) {
    main_py();
}