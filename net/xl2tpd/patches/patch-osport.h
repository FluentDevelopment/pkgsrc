$NetBSD$

--- osport.h.orig	2016-08-12 00:56:53.000000000 +0000
+++ osport.h
@@ -35,7 +35,7 @@
 
 #endif /* defined(SOLARIS) */
 
-#if !defined(LINUX)
+#if !defined(IP_PKTINFO)
 
 /* Declare empty structure to make code portable and keep simple */
 struct in_pktinfo {
