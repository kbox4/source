82c82
<         exit(atoi(pointer));
---
>         _Exit(atoi(pointer));
122d121
< #define NEW
125d123
< #ifdef OLD
127c125
<     if (!(w->nextfunc = dlsym(RTLD_NEXT, w->name))) {
---
>     if (!(w->nextfunc = dlsym(RTLD_NEXT, w->name))) {;
132,140d129
<     return w->nextfunc;
< #else
<   char *msg;
<   if (!(w->nextfunc = dlsym(strcmp(w->name, "dlopen")?RTLD_NEXT : RTLD_DEFAULT, w->name))) {
<     msg = dlerror();
<     fprintf(stderr, "%s: %s: %s\n", PACKAGE, w->name, msg != NULL ? msg : "unresolved symbol");
<     exit(EXIT_FAILURE);
<     }
< #endif
