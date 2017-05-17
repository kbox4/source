2719c2719
<             flags |= AT_EACCESS;
---
>             flags |= 0;
6072,6073c6072,6073
<     ioctl(slave_fd, I_PUSH, "ptem"); /* push ptem */
<     ioctl(slave_fd, I_PUSH, "ldterm"); /* push ldterm */
---
>     //ioctl(slave_fd, I_PUSH, "ptem"); /* push ptem */
>     //ioctl(slave_fd, I_PUSH, "ldterm"); /* push ldterm */
6075c6075
<     ioctl(slave_fd, I_PUSH, "ttcompat"); /* push ttcompat */
---
>     //ioctl(slave_fd, I_PUSH, "ttcompat"); /* push ttcompat */
