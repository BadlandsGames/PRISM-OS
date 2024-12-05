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

#include <iostream>
using namespace std;

static void update(void) __dead2;
static void usage(void) __dead2;

static void update(void) {
    system("apk update && pkg update && apt update");
    system("ubuntu-drivers autoinstall");
    system("apk update && pkg update && apt update");
}

static void usage(void) {
    cout << (
        "" << endl <<
        ""
    );
}

int main(int argc, char *argv[]) {
    return 0;
}