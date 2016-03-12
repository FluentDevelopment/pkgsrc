$NetBSD$

Allow overriding hard-coded path to chroot without causing a compiler warning.

--- src/constants.h.orig	2015-06-22 05:21:14.000000000 +0000
+++ src/constants.h
@@ -33,7 +33,9 @@
 #define GREYD_MAIN_USER     "greyd"
 #define GREYD_DB_USER       "greydb"
 #define GREYD_CHROOT        1
+#ifndef GREYD_CHROOT_DIR
 #define GREYD_CHROOT_DIR    "/var/empty"
+#endif
 #define GREYD_BACKLOG       10
 #define MAX_FILES_THRESHOLD 200
 #define MAX_TIME            400
