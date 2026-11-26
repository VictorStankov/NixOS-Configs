// SACTools/SACMonitor detect a running instance by scanning /proc and resolving
// each process's argv[0]. Processes started as "/proc/self/exe" (Electron/Chromium
// helpers) then resolve to SAC's own binary and get mistaken for a running copy.
// Hide those processes from the /proc listing.
#define _GNU_SOURCE
#include <dirent.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static DIR *proc_dir;

DIR *opendir(const char *name) {
  static DIR *(*real)(const char *);
  if (!real) real = dlsym(RTLD_NEXT, "opendir");
  DIR *d = real(name);
  if (d && (strcmp(name, "/proc") == 0 || strcmp(name, "/proc/") == 0)) proc_dir = d;
  return d;
}

static int argv0_is_proc_self(const char *pid) {
  char path[64], buf[16] = {0};
  snprintf(path, sizeof path, "/proc/%s/cmdline", pid);
  int fd = open(path, O_RDONLY | O_CLOEXEC);
  if (fd < 0) return 0;
  ssize_t n = read(fd, buf, sizeof buf - 1);
  close(fd);
  return n > 0 && strncmp(buf, "/proc/self/", 11) == 0;
}

struct dirent *readdir(DIR *d) {
  static struct dirent *(*real)(DIR *);
  if (!real) real = dlsym(RTLD_NEXT, "readdir");
  struct dirent *e;
  while ((e = real(d)) && d == proc_dir && argv0_is_proc_self(e->d_name)) {
  }
  return e;
}

int closedir(DIR *d) {
  static int (*real)(DIR *);
  if (!real) real = dlsym(RTLD_NEXT, "closedir");
  if (d == proc_dir) proc_dir = NULL;
  return real(d);
}
