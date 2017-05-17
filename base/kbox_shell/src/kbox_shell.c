#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

// We will be called as /data/data/kevinboone.androidterm/kbox3/bin/kbox_shell

int main (int argc, char **argv)
  {
  char self[512];
  char root[512];
  char bin[512];
  char kbox[512];
  char kbox_bin[512];
  char usr_bin[512];
  char bb_target[512];
  char *env[30];
  char *user_id;
  int i = 0;
  int uid = 0;

  int l = readlink ("/proc/self/exe", self, sizeof (self) - 1); 
  self[l] = 0;
  strcpy (bin, self);

#ifdef DEBUG
  strcpy (bin, "/data/data/jackpal.androidterm/kbox3/bin/kbox_shell");
#endif

  char *p = strrchr (bin, '/');
  if (p == NULL)
    strcpy (bin, ""); 
  else
    {
    *p = 0;
    }

#ifdef DEBUG
  printf ("My binary dir is %s\n", bin);
#endif
  
  strcpy (root, bin);
  p = strrchr (root, '/');
  if (p == NULL)
    strcpy (root, ""); 
  else
    {
    *p = 0;
    }
  
  // root = /data/data/kevinboone.androidterm

#ifdef DEBUG
  printf ("My root dir is %s\n", bin);
#endif
  

  strcpy (kbox, root);
  mkdir (kbox, 0755);

  // kbox = /data/data/kevinboone.androidterm/kbox
  
  strcpy (kbox_bin, kbox);
  strcat (kbox_bin, "/");
  strcat (kbox_bin, "bin");
  mkdir (kbox_bin, 0755);

  strcpy (usr_bin, kbox);
  strcat (usr_bin, "/");
  strcat (usr_bin, "usr/bin");
  mkdir (usr_bin, 0755);

#ifdef DEBUG
  printf ("Created bin and usr/bin\n");
#endif

  // kbox_bin = /data/data/kevinboone.androidterm/kbox/bin
  
  strcpy (bb_target, kbox_bin);
  strcat (bb_target, "/");
  strcat (bb_target, "busybox");

#ifdef DEBUG
  printf ("bb_target is %s\n", bb_target);
#endif

   
  uid = getuid ();
  struct passwd *pw = getpwuid (uid);
  if (pw->pw_name) user_id = pw->pw_name; else user_id = "user";

#ifdef DEBUG
  printf ("uid is %d, pw_name is %s\n", uid, user_id);
#endif

  char ss[1024];
  i = 0;
  sprintf (ss, "PATH=%s:%s:/data/local/bin:/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin:/system/bin:/bin:/usr/bin", bin, usr_bin);
  env[i] = strdup (ss);
  i++;

  env[i] = strdup ("ANDROID_DATA=/data");
  i++;
  env[i] = strdup ("ANDROID_ROOT=/system");
  i++;

  sprintf (ss, "USER=%s", user_id);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "USERNAME=%s", user_id);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "LOGNAME=%s", user_id);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "LD_LIBRARY_PATH=%s/lib:%s/usr/lib", kbox, kbox);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "KBOX=%s", kbox);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "FAKECHROOT_EXCLUDE_PATH=%s:%s", kbox, root);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "LD_PRELOAD=%s/lib/libfakechroot.so", kbox);
  env[i] = strdup (ss);
  i++;
  sprintf (ss, "FAKECHROOT_BASE=%s", kbox);
  env[i] = strdup (ss);
  i++;
  env[i] = 0;

#ifdef DEBUG
  char **e = env;
  while (*e)
    {
    printf ("env: %s\n", *e);
    *e++;
    } 
#endif


  if (argc > 1)
    {
    // We received some arguments
    int i = 0;
    //for (i = 0; i < argc; i++)
    //  {
    //  printf ("arg%d: %s\n", i, argv[i]);
    //  }
    char **newargs = (char **)malloc ((argc + 10) * sizeof (char *));
    newargs[0] = bb_target; 
    newargs[1] = "bash"; 
    newargs[2] = "-l"; 
    for (i = 1; i < argc; i++)
      {
      newargs[i+2] = strdup (argv[i]);
      }
    newargs[i+2] = 0;

    int r = execve (bb_target, newargs, env);
    printf ("excve returns %d; error is %d\n", r, errno);
    }
  else
    { 
    int r = execle (bb_target, bb_target, "bash", "-l", NULL, env);
    printf ("excle returns %d; error is %d\n", r, errno);
    }
  }


