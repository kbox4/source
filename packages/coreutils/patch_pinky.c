244c244
<           char *const comma = strchr (pw->pw_gecos, ',');
---
>           char *const comma = strchr ("kbox", ',');
250c250
<           result = create_fullname (pw->pw_gecos, pw->pw_name);
---
>           result = create_fullname ("kbox", pw->pw_name);
325c325
<       char *const comma = strchr (pw->pw_gecos, ',');
---
>       char *const comma = strchr ("kbox", ',');
331c331
<       result = create_fullname (pw->pw_gecos, pw->pw_name);
---
>       result = create_fullname ("kbox", pw->pw_name);
