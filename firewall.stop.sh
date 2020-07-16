#!/bin/bash
IPTABLES=/sbin/iptables
# Limpa todas as Rules em todas as tabelas
$IPTABLES -t filter -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
# Remove todas as Chains em todas as tabelas
$IPTABLES -t filter -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X
# Zera todos os contadores de todas as Chains em todas as tabelas
$IPTABLES -t filter -Z
$IPTABLES -t nat -Z
$IPTABLES -t mangle -Z
# Aceita tudo por default (policy = ACCEPT)
$IPTABLES -t filter -P INPUT ACCEPT
$IPTABLES -t filter -P FORWARD ACCEPT
$IPTABLES -t filter -P OUTPUT ACCEPT
service fail2ban stop