# $NetBSD: buildlink3.mk,v 1.7 2004/02/05 07:06:15 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PAM_BUILDLINK3_MK:=	${PAM_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(PAM_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		pam
BUILDLINK_DEPENDS.pam+=		PAM>=0.75
BUILDLINK_PKGSRCDIR.pam?=	../../security/PAM
.endif	# PAM_BUILDLINK3_MK

BUILDLINK_CHECK_BUILTIN.pam?=	NO

.if !defined(BUILDLINK_IS_BUILTIN.pam)
BUILDLINK_IS_BUILTIN.pam=	NO
.  if exists(/usr/include/security/pam_appl.h)
BUILDLINK_IS_BUILTIN.pam=	YES
.  endif
.endif

.if defined(PREFER_PKGSRC)
.  if empty(PREFER_PKGSRC) || !empty(PREFER_PKGSRC:M[yY][eE][sS]) || \
      !empty(PREFER_PKGSRC:Mpam)
BUILDLINK_USE_BUILTIN.pam=	NO
.  endif
.endif

.if !empty(BUILDLINK_CHECK_BUILTIN.pam:M[yY][eE][sS])
BUILDLINK_USE_BUILTIN.pam=	YES
.endif

.if !defined(BUILDLINK_USE_BUILTIN.pam)
.  if !empty(BUILDLINK_IS_BUILTIN.pam:M[nN][oO])
BUILDLINK_USE_BUILTIN.pam=	NO
.  else
BUILDLINK_USE_BUILTIN.pam=	YES
.  endif
.endif

.if !empty(BUILDLINK_USE_BUILTIN.pam:M[nN][oO])
.  if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pam
.  endif
.endif

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
