$NetBSD: patch-tools_xenstore_xc.c,v 1.1 2017/03/30 09:15:10 bouyer Exp $

--- tools/xenstore/xs.c.orig	2015-01-19 15:40:00.000000000 +0100
+++ tools/xenstore/xs.c	2015-01-19 15:46:56.000000000 +0100
@@ -725,9 +725,13 @@
 
 #ifdef USE_PTHREAD
 #define DEFAULT_THREAD_STACKSIZE (16 * 1024)
+#ifndef PTHREAD_STACK_MIN
+#define READ_THREAD_STACKSIZE DEFAULT_THREAD_STACKSIZE
+#else
 #define READ_THREAD_STACKSIZE 					\
 	((DEFAULT_THREAD_STACKSIZE < PTHREAD_STACK_MIN) ? 	\
 	PTHREAD_STACK_MIN : DEFAULT_THREAD_STACKSIZE)
+#endif
 
 	/* We dynamically create a reader thread on demand. */
 	mutex_lock(&h->request_mutex);
