$NetBSD: patch-md5.c,v 1.2 2013/07/12 19:06:31 christos Exp $

Include endian.h for NetBSD
memset the right size, not just the first sizeof(ptr) bits.

--- md5.c.orig	2016-08-12 00:56:53.000000000 +0000
+++ md5.c
@@ -7,6 +7,8 @@
 # include <endian.h>
 #elif defined(SOLARIS)
 # include <sys/isa_defs.h>
+#elif defined(NETBSD)
+# include <sys/endian.h>
 #endif
 #if __BYTE_ORDER == __BIG_ENDIAN
 #define HIGHFIRST 1
