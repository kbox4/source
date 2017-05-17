257d256
< #ifdef MS_WINDOWS
258a258
> #ifdef MS_WINDOWS
269c269,270
<     PyErr_SetNone(PyExc_NotImplementedError);
---
>     PyOS_snprintf(codepage, sizeof(codepage), "utf-8");
>     return get_codec_name(codepage);
271a273
>     return NULL;
