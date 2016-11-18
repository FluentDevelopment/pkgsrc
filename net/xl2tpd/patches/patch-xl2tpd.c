$NetBSD: patch-xl2tpd.c,v 1.2 2014/02/14 22:06:39 christos Exp $

Expose functions

--- xl2tpd.c.orig	2016-08-12 00:56:53.000000000 +0000
+++ xl2tpd.c
@@ -19,6 +19,7 @@
 #define _BSD_SOURCE
 #define _XOPEN_SOURCE_EXTENDED	1
 #define _GNU_SOURCE
+#define _NETBSD_SOURCE
 
 #include <stdlib.h>
 #include <sys/types.h>
