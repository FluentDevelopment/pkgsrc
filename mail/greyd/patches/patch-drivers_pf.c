$NetBSD$

The upstream pf.c driver calls signal(3) with 3 arguments... neither OpenBSD, NetBSD, FreeBSD, DragonFlyBSD or Linux
seem to have a 3-argument version of signal(3)! This patches removes the third (NULL) argument, which fixes the
build error in pf.c.

--- drivers/pf.c.orig	2015-06-22 05:21:14.000000000 +0000
+++ drivers/pf.c
@@ -187,7 +187,13 @@ Mod_fw_replace(FW_handle_T handle, const
         goto err;
     }
 
+#if defined(__OpenBSD__) || defined(__NetBSD__) || defined(__FreeBSD__)
+    signal(SIGCHLD, &oldact);
+#else
+    /* This was the original signal(3) call but I don't know what OS supports a 3-argument version
+     * of signal(3)? Leaving it here just in case. */ 
     signal(SIGCHLD, &oldact, NULL);
+#endif
 
     return nadded;
 
