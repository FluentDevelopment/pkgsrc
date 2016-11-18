$NetBSD: patch-misc.c,v 1.1 2013/07/12 19:06:31 christos Exp $

Declare inline in a separate file.

--- misc.c.orig	2016-08-12 00:56:53.000000000 +0000
+++ misc.c
@@ -175,33 +175,6 @@ void do_packet_dump (struct buffer *buf)
     printf ("}\n");
 }
 
-void swaps (void *buf_v, int len)
-{
-#ifdef __alpha
-    /* Reverse byte order alpha is little endian so lest save a step.
-       to make things work out easier */
-    int x;
-    unsigned char t1;
-    unsigned char *tmp = (_u16 *) buf_v;
-    for (x = 0; x < len; x += 2)
-    {
-        t1 = tmp[x];
-        tmp[x] = tmp[x + 1];
-        tmp[x + 1] = t1;
-    }
-#else
-
-    /* Reverse byte order (if proper to do so) 
-       to make things work out easier */
-    int x;
-	struct hw { _u16 s; } __attribute__ ((packed)) *p = (struct hw *) buf_v;
-	for (x = 0; x < len / 2; x++, p++)
-		p->s = ntohs(p->s); 
-#endif
-}
-
-
-
 inline void toss (struct buffer *buf)
 {
     /*
