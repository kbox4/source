20,36d19
< #ifdef USE_LUTIMES
< #ifdef UNIX_TIME_NS
<   timespec times[2];
<   times[0].tv_sec=fta->GetUnix();
<   times[0].tv_nsec=fta->IsSet() ? long(fta->GetUnixNS()%1000000000) : UTIME_NOW;
<   times[1].tv_sec=ftm->GetUnix();
<   times[1].tv_nsec=ftm->IsSet() ? long(ftm->GetUnixNS()%1000000000) : UTIME_NOW;
<   utimensat(AT_FDCWD,LinkNameA,times,AT_SYMLINK_NOFOLLOW);
< #else
<   struct timeval tv[2];
<   tv[0].tv_sec=fta->GetUnix();
<   tv[0].tv_usec=long(fta->GetUnixNS()%1000000000/1000);
<   tv[1].tv_sec=ftm->GetUnix();
<   tv[1].tv_usec=long(ftm->GetUnixNS()%1000000000/1000);
<   lutimes(LinkNameA,tv);
< #endif
< #endif
