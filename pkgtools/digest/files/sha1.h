/*	$NetBSD: sha1.h,v 1.5 2007/08/02 13:54:34 joerg Exp $	*/

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 */

#ifndef _SYS_SHA1_H_
#define	_SYS_SHA1_H_

#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif

#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif

typedef struct {
	uint32_t state[5];
	uint32_t count[2];  
	u_char buffer[64];
} SHA1_CTX;
  
void	SHA1Transform __P((uint32_t state[5], const u_char buffer[64]));
void	SHA1Init __P((SHA1_CTX *context));
void	SHA1Update __P((SHA1_CTX *context, const u_char *data, u_int len));
void	SHA1Final __P((u_char digest[20], SHA1_CTX *context));
#ifndef _KERNEL
char	*SHA1End __P((SHA1_CTX *, char *));
char	*SHA1File __P((char *, char *));
char	*SHA1Data __P((const u_char *, size_t, char *));
#endif /* _KERNEL */

#endif /* _SYS_SHA1_H_ */
