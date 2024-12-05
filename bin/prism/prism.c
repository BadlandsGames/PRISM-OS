/*
apk update && pkg update && apt update
ubuntu-drivers autoinstall
apk update && pkg update && apt update
*/
#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef SHELL
#define main killcmd
#include "bltin/bltin.h"
#endif

static void usage(void) __dead2;

int main(int argc, char *argv[]) {
}

static void usage(void) {
	(void)fprintf(stderr, "%s\n%s\n%s\n%s\n",
		"usage: kill [-s signal_name] pid ...",
		"       kill -l [exit_status]",
		"       kill -signal_name pid ...",
		"       kill -signal_number pid ...");
#ifdef SHELL
	error(NULL);
#else
	exit(2);
#endif
}