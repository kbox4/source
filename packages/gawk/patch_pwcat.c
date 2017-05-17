26,39c26
<     struct passwd *p;
< 
<     while ((p = getpwent()) != NULL)
< #ifdef HAVE_STRUCT_PASSWD_PW_PASSWD
<         printf("%s:%s:%ld:%ld:%s:%s:%s\n",
<             p->pw_name, p->pw_passwd, (long) p->pw_uid,
<             (long) p->pw_gid, p->pw_gecos, p->pw_dir, p->pw_shell);
< #else
<         printf("%s:*:%ld:%ld:%s:%s\n",
<             p->pw_name, (long) p->pw_uid,
<             (long) p->pw_gid, p->pw_dir, p->pw_shell);
< #endif
< 
<     endpwent();
---
>     printf ("There is no password database on Android\n");
