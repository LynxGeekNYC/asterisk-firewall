#!/bin/bash
IPTABLES=/sbin/iptables
# Clear all Rules on all tables
$IPTABLES -t filter -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
# Removes all Chains in all tables
$IPTABLES -t filter -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X
# Reset all counters for all Chains in all tables
$IPTABLES -t filter -Z
$IPTABLES -t nat -Z
$IPTABLES -t mangle -Z
# Accept everything by default (policy = ACCEPT)
$IPTABLES -t filter -P INPUT ACCEPT
$IPTABLES -t filter -P FORWARD ACCEPT
$IPTABLES -t filter -P OUTPUT ACCEPT
service fail2ban stop
