$NetBSD: patch-network.c,v 1.4 2015/02/19 22:27:59 joerg Exp $

Handle not having IP_PKTINFO
Handle not having SO_NO_CHECK
Don't set control buf if controllen == 0
Avoid pointer aliasing issue and fix test that was done in the wrong
byte order

--- network.c.orig	2016-08-12 00:56:53.000000000 +0000
+++ network.c
@@ -87,17 +87,18 @@ int init_network (void)
 
 	    gconfig.ipsecsaref=0;
     }
-
-    arg=1;
-    if(setsockopt(server_socket, IPPROTO_IP, IP_PKTINFO, (char*)&arg, sizeof(arg)) != 0) {
-	    l2tp_log(LOG_CRIT, "setsockopt IP_PKTINFO: %s\n", strerror(errno));
-    }
 #else
     {
 	l2tp_log(LOG_INFO, "No attempt being made to use IPsec SAref's since we're not on a Linux machine.\n");
     }
-
 #endif
+#ifdef IP_PKTINFO
+    arg=1;
+    if(setsockopt(server_socket, IPPROTO_IP, IP_PKTINFO, (char*)&arg, sizeof(arg)) != 0) {
+	    l2tp_log(LOG_CRIT, "setsockopt IP_PKTINFO: %s\n", strerror(errno));
+    }
+#endif
+
 
 #ifdef USE_KERNEL
     if (gconfig.forceuserspace)
@@ -155,10 +156,8 @@ static inline void fix_hdr (void *buf)
     /*
      * Fix the byte order of the header
      */
-
-    struct payload_hdr *p = (struct payload_hdr *) buf;
-    _u16 ver = ntohs (p->ver);
-    if (CTBIT (p->ver))
+    _u16 ver = ntohs (*(_u16 *)buf);
+    if (CTBIT (ver))
     {
         /*
          * Control headers are always
@@ -275,7 +274,11 @@ void control_xmit (void *b)
 void udp_xmit (struct buffer *buf, struct tunnel *t)
 {
     struct cmsghdr *cmsg = NULL;
-    char cbuf[CMSG_SPACE(sizeof (unsigned int) + sizeof (struct in_pktinfo))];
+    char cbuf[CMSG_SPACE(sizeof (unsigned int)
+#ifdef IP_PKTINFO
+    + sizeof (struct in_pktinfo)
+#endif
+    )];
     unsigned int *refp;
     struct msghdr msgh;
     int err;
@@ -304,7 +307,7 @@ void udp_xmit (struct buffer *buf, struc
 	finallen = cmsg->cmsg_len;
     }
 
-#ifdef LINUX
+#ifdef IP_PKTINFO
     if (t->my_addr.ipi_addr.s_addr){
 	struct in_pktinfo *pktinfo;
 
@@ -428,7 +431,9 @@ void network_thread ()
      * our network socket.  Control handling is no longer done here.
      */
     struct sockaddr_in from;
+#ifdef IP_PKTINFO
     struct in_pktinfo to;
+#endif
     unsigned int fromlen;
     int tunnel, call;           /* Tunnel and call */
     int recvsize;               /* Length of data received */
@@ -509,7 +514,9 @@ void network_thread ()
             buf->len -= PAYLOAD_BUF;
 
 	    memset(&from, 0, sizeof(from));
+#ifdef IP_PKTINFO
 	    memset(&to,   0, sizeof(to));
+#endif
 
 	    fromlen = sizeof(from);
 
@@ -561,7 +568,7 @@ void network_thread ()
 		for (cmsg = CMSG_FIRSTHDR(&msgh);
 			cmsg != NULL;
 			cmsg = CMSG_NXTHDR(&msgh,cmsg)) {
-#ifdef LINUX
+#ifdef IP_PKTINFO
 			/* extract destination(our) addr */
 			if (cmsg->cmsg_level == IPPROTO_IP && cmsg->cmsg_type == IP_PKTINFO) {
 				struct in_pktinfo* pktInfo = ((struct in_pktinfo*)CMSG_DATA(cmsg));
@@ -598,6 +605,8 @@ void network_thread ()
 
 	    if (gconfig.packet_dump)
 	    {
+       		struct payload_hdr *p = (struct payload_hdr *) buf->start;
+       		l2tp_log(LOG_DEBUG, "ver = 0x%x\n", p->ver);
 		do_packet_dump (buf);
 	    }
 
@@ -629,9 +638,11 @@ void network_thread ()
         }
         else
         {
+#ifdef IP_PKTINFO
             if (c->container) {
                 c->container->my_addr = to;
             }
+#endif
 
             buf->peer = from;
             /* Handle the packet */
