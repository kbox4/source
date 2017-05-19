1010,1011c1010,1011
< 	setpwent();
< 	while((pw = getpwent()) != NULL)
---
> 	//setpwent();
> 	while((pw = NULL) != NULL)
1013,1016c1013,1016
< 		if(strncmp(pw->pw_name, str, len) == 0)
< 		{
< 			vle_compl_add_match(pw->pw_name, "");
< 		}
---
> 	//	if(strncmp(pw->pw_name, str, len) == 0)
> 	//	{
> 	//		vle_compl_add_match(pw->pw_name, "");
> 	//	}
1026c1026
< 	size_t len = strlen(str);
---
> //	size_t len = strlen(str);
1028,1029c1028,1029
< 	setgrent();
< 	while((gr = getgrent()) != NULL)
---
> //	setgrent();
> 	while((gr = NULL) != NULL)
1031,1034c1031,1034
< 		if(strncmp(gr->gr_name, str, len) == 0)
< 		{
< 			vle_compl_add_match(gr->gr_name, "");
< 		}
---
> //		if(strncmp(gr->gr_name, str, len) == 0)
> //		{
> //			vle_compl_add_match(gr->gr_name, "");
> //		}
