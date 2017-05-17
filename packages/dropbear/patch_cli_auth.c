34a35,99
> /*=========================================================================
> Added by KB
> =========================================================================*/
> 
> typedef int bool;
> #define false 0
> #define __fsetlocking(stream,type)
> #define TCSASOFT 0
> 
> 
> char *getpass (const char *prompt)
>   {
>   FILE *tty;
>   FILE *in, *out;
>   struct termios s, t;
>   bool tty_changed = false;
>   static char buf[256];
>   static size_t bufsize;
>   ssize_t nread;
> 
>   tty = fopen ("/dev/tty", "w+");
>   if (tty == NULL)
>     {
>       in = stdin;
>       out = stderr;
>     }
>   else
>     {
>       /* We do the locking ourselves.  */
>       __fsetlocking (tty, FSETLOCKING_BYCALLER);
> 
>       out = in = tty;
>     }
> 
> 
>   if (tcgetattr (fileno (in), &t) == 0)
>     {
>       /* Save the old one. */
>       s = t;
>       /* Tricky, tricky. */
>       t.c_lflag &= ~(ECHO | ISIG);
>       tty_changed = (tcsetattr (fileno (in), TCSAFLUSH | TCSASOFT, &t) == 0);
>     }
> 
>   fputs (prompt, out);
>   fflush (out);
>   
>   buf[0] = 0;
>   fgets (buf, sizeof (buf) - 1, in);
>   buf[strlen(buf) - 1] = 0; // CHOMP EOL 
>   
>   if (tty_changed)
>     tcsetattr (fileno (in), TCSAFLUSH | TCSASOFT, &s);
> 
>   printf ("\n");
>   return buf; 
>   }
> 
> 
> /*=========================================================================
> End added by KB
> =========================================================================*/
> 
> 
> 
351a417,420
> 
> 
> 
> 
