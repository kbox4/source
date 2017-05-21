95a96,104
> int mblen (const char *s, size_t n)
>   {
>   if (!s) return 0;
>   if (!*s) return -1;
>   int c = 0;
>   while ((*s & 0xC0) == 0x80 && c < n) { c++; s++; }
>   return c;
>   }
> 
375,379c384,388
< #ifdef HAVE_DN_EXPAND // newer resolver versions have dn_expand and dn_skipname
<    if(store)
<       dn_expand(answer,scan+len,scan,store,store_len);
<    return dn_skipname(scan,scan+len);
< #else // ...older don't.
---
> //#ifdef HAVE_DN_EXPAND // newer resolver versions have dn_expand and dn_skipname
> //   if(store)
> //      dn_expand(answer,scan+len,scan,store,store_len);
> //   return dn_skipname(scan,scan+len);
> //#else // ...older don't.
436c445
< #endif // DN_EXPAND
---
> //#endif // DN_EXPAND
