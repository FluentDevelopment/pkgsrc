$NetBSD$

Fix call to IP_str_to_addr_mask with final "sa_family_t *af" argument.

--- drivers/npf.c.orig	2015-06-22 05:21:14.000000000 +0000
+++ drivers/npf.c
@@ -135,7 +135,7 @@ Mod_fw_replace(FW_handle_T handle, const
     /* This should somehow be atomic. */
     LIST_EACH(cidrs, entry) {
         if((cidr = List_entry_value(entry)) != NULL
-            && IP_str_to_addr_mask(cidr, &n, &m) != -1) 
+            && IP_str_to_addr_mask(cidr, &n, &m, &af) != -1) 
         {
             ret = sscanf(cidr, "%39[^/]/%u", parsed, &maskbits);
             if(ret != 2 || maskbits == 0 || maskbits > IP_MAX_MASKBITS)
