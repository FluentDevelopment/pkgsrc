$NetBSD$

--- l2tp.h.orig	2016-08-12 00:56:53.000000000 +0000
+++ l2tp.h
@@ -30,13 +30,13 @@ typedef unsigned long long _u64;
 #endif
 #include "osport.h"
 #include "scheduler.h"
+#include "common.h"
 #include "misc.h"
 #include "file.h"
 #include "call.h"
 #include "avp.h"
 #include "control.h"
 #include "aaa.h"
-#include "common.h"
 #include "ipsecmast.h"
 
 #define CONTROL_PIPE "/var/run/xl2tpd/l2tp-control"
@@ -182,7 +182,9 @@ struct tunnel
     struct call *self;
     struct lns *lns;            /* LNS that owns us */
     struct lac *lac;            /* LAC that owns us */
+#ifdef IP_PKTINFO
     struct in_pktinfo my_addr;  /* Address of my endpoint */
+#endif
     char hostname[MAXSTRLEN];   /* Remote hostname */
     char vendor[MAXSTRLEN];     /* Vendor of remote product */
     struct challenge chal_us;   /* Their Challenge to us */
