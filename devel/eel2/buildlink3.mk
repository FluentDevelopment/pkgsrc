# $NetBSD: buildlink3.mk,v 1.3 2004/03/05 19:25:10 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
EEL2_BUILDLINK3_MK:=	${EEL2_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	eel2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Neel2}
BUILDLINK_PACKAGES+=	eel2

.if !empty(EEL2_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.eel2+=	eel2>=2.4.1nb2
BUILDLINK_PKGSRCDIR.eel2?=	../../devel/eel2

.include "../../devel/GConf2/buildlink3.mk"
.include "../../devel/gail/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../devel/libglade2/buildlink3.mk"
.include "../../devel/libgnome/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"
.include "../../graphics/libart2/buildlink3.mk"
.include "../../sysutils/gnome-vfs2/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"

.endif	# EEL2_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
