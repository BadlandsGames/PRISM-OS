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

#define newtab_cout (" " << " " << " " << " ")

static void update(void) __dead2;
static void restart(string service_to_restart) __dead2;
static void busybox(string cmd) __dead2;
static void toybox(string cmd) __dead2;

static void usage(void) __dead2;

static void update(void) {
    system("apk update && pkg update && apt update && apt upgrade");
    system("ubuntu-drivers autoinstall");
    system("apk update && pkg update && apt update && apt upgrade");
}

static void restart(string service_to_restart) {
    string newcmd = "";
    newcmd.append("service");
    newcmd.append(" ");
    newcmd.append(service_to_restart);
    newcmd.append(" ");
    newcmd.append("restart");
    system(newcmd);
}

static void busybox(string cmd) {
    string newcmd = "";
    newcmd.append("busybox");
    newcmd.append(" ");
    newcmd.append(cmd);
    system(newcmd);
}

static void toybox(string cmd) {
    string newcmd = "";
    newcmd.append("toybox");
    newcmd.append(" ");
    newcmd.append(cmd);
    system(newcmd);
}

static void install_android(string path) {
    string newcmd = "";
    newcmd.append("apk add --allow-untrusted");
    newcmd.append(" ");
    newcmd.append(path);
    system(newcmd);
}

static void install_debian(string path) {
    string newcmd = "";
    newcmd.append("dpkg -i");
    newcmd.append(" ");
    newcmd.append(path);
    system(newcmd);
}

static void install_pkg(string path) {
    string newcmd = "";
    newcmd.append("pkg add");
    newcmd.append(" ");
    newcmd.append(path);
    system(newcmd);
}

static void usage(void) {
    cout << (
        "usage: prism" << endl <<
        newtab_cout << "--update" << endl <<
        newtab_cout << "--restart <service>" << endl <<
        newtab_cout << "--install-android <path>" << endl <<
        newtab_cout << "--install-debian <path>" << endl <<
        newtab_cout << "--install-pkg <path>" << endl <<
        newtab_cout << "--busybox <cmd>" << endl <<
        newtab_cout << "--toybox <cmd>"
    );
}

int main(int argc, char *argv[]) {
    if(!strcmp(*argv, "--update")) {
		argc--, argv++;
		if (argc < 1) {
			update();
		}
        if(strcmp(*argv, "0")) {
			usage();
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--install-android")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			install_android(*argv);
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--install-debian")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			install_debian(*argv);
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--install-pkg")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			install_pkg(*argv);
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--restart")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			restart(*argv);
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--busybox")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			busybox(*argv);
		}
        argc--, argv++;
    }
    else if(!strcmp(*argv, "--toybox")) {
		argc--, argv++;
		if (argc < 1) {
			usage();
		}
        if(strcmp(*argv, "0")) {
			toybox(*argv);
		}
        argc--, argv++;
    }
    return 0;
}