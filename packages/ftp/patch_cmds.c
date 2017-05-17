47a48
> #include <termio.h>
91a93,133
> 
> /*========================================================================
>   mygetpass
> =========================================================================*/
> char *getpass (const char *prompt)
>   {
>   char password[64];
>   memset (password, 0, sizeof (password));
> 
>   struct termios oflags, nflags;
> 
>   tcgetattr(fileno(stdin), &oflags);
>   nflags = oflags;
>   nflags.c_lflag &= ~ECHO;
> //  nflags.c_lflag |= ECHONL;
>   tcsetattr(fileno(stdin), TCSANOW, &nflags); 
> 
>   fprintf(stderr, prompt);
>   fflush (stdout);
>   FILE *f = fopen ("/dev/tty", "r");
>   if (f)
>     {
>     fgets(password, sizeof(password), f);
>     fclose (f);
>     }
>   else
>     fgets(password, sizeof(password), stdin);
>    
>   if (strlen (password) > 0)
>     password[strlen(password) - 1] = 0; // remove \n
> 
>   fseek (stderr, 0, SEEK_CUR);
> 
>   tcsetattr(fileno(stdin), TCSANOW, &oflags); 
> 
>   printf ("\n");
> 
>   return strdup (password);
>   }
> 
> 
