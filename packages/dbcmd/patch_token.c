56c56,67
<   fgets (s, sizeof (s) - 1, stdin);
---
> 
>   // Horrible kludge for later version of the Google NDK where
>   //  fgets (...stdin) DOES NOT F*CKING WORK!
>   FILE *f = fopen ("/dev/tty", "r");
>   if (f)
>     {
>     fgets (s, sizeof (s) - 1, f);
>     fclose (f);
>     }
>   else
>     fgets (s, sizeof (s) - 1, stdin); // Won't work, but what can we do?
> 
