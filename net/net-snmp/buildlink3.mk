# $NetBSD: buildlink3.mk,v 1.5 2005/05/27 13:47:39 salo Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
NET_SNMP_BUILDLINK3_MK:=	${NET_SNMP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	net-snmp
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nnet-snmp}
BUILDLINK_PACKAGES+=	net-snmp

.if !empty(NET_SNMP_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.net-snmp+=	net-snmp>=5.0.9nb3
BUILDLINK_RECOMMENDED.net-snmp+=	net-snmp>=5.2.1nb1
BUILDLINK_PKGSRCDIR.net-snmp?=	../../net/net-snmp
.endif	# NET_SNMP_BUILDLINK3_MK

.include "../../security/tcp_wrappers/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
