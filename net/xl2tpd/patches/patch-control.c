$NetBSD: patch-control.c,v 1.2 2013/07/18 12:06:39 joerg Exp $

Remove static from inline; each inlined copy might have its own buffer and
this is not want you want if you define it static. In this case it does not
matter, since it is only 4K and we don't return it, so don't try to play
around with saving stack space for no good reason.

--- control.c.orig	2016-08-12 00:56:53.000000000 +0000
+++ control.c
@@ -75,7 +75,7 @@ struct buffer *new_outgoing (struct tunn
     return tmp;
 }
 
-inline void recycle_outgoing (struct buffer *buf, struct sockaddr_in peer)
+void recycle_outgoing (struct buffer *buf, struct sockaddr_in peer)
 {
     /*
      * This should only be used for ZLB's!
@@ -1600,7 +1600,7 @@ static inline int write_packet (struct b
     int x;
     unsigned char e;
     int err;
-    static unsigned char wbuf[MAX_RECV_SIZE];
+    unsigned char wbuf[MAX_RECV_SIZE];
     int pos = 0;
 
     if (c->fd < 0)
@@ -1770,7 +1770,7 @@ int handle_special (struct buffer *buf, 
     return 0;
 }
 
-inline int handle_packet (struct buffer *buf, struct tunnel *t,
+int handle_packet (struct buffer *buf, struct tunnel *t,
                           struct call *c)
 {
     int res;
