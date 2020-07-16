#!/bin/bash

RANGEBRASIL="/usr/RANGE"
CONFIG="/usr/firewall.conf"
IPTABLES=/sbin/iptables
	
		service fail2ban stop

		echo ""
		echo "#######################################"
		echo "########## Asterisk FireWall ##########"
		echo "#######################################"
		echo ""

# Clear Table
		# Clear All Rules on All tables
		$IPTABLES -t filter -F
		$IPTABLES -t nat -F
		$IPTABLES -t mangle -F
		# Remove all Chains in All tables
		$IPTABLES -t filter -X
		$IPTABLES -t nat -X
		$IPTABLES -t mangle -X
		#Reset all counters for all Chains in all tables
		$IPTABLES -t filter -Z
		$IPTABLES -t nat -Z
		$IPTABLES -t mangle -Z
		echo ""
		echo "##### RESETTING ALL RULES..............[OK]"
# Load the Modules
		modprobe ip_tables
		modprobe iptable_filter
		modprobe iptable_mangle
		modprobe iptable_nat
		modprobe ipt_MASQUERADE

# Releases kernel ping, can be changed to 1 to disable ping
		echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

# sets syn_cookie to prevent syn_flood attack
		echo "1" > /proc/sys/net/ipv4/tcp_syncookies

# Protege contra IP spoofing
		echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Discards malformed packages, protecting against various attacks:
		$IPTABLES -I INPUT -m state --state INVALID -j DROP
		
# Releases loopback and connections initiated by the server
		$IPTABLES -I INPUT -d 127.0.0.1 -j ACCEPT
		$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
		$IPTABLES -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		
		echo ""
		echo "##### LOADING STANDARD TABLE POLICIES"
		
		
# Defines the DEFAULT policy of the TABLES

		$IPTABLES -P INPUT DROP
		$IPTABLES -P OUTPUT ACCEPT
		$IPTABLES -P FORWARD DROP

		echo "##### STANDARD TABLE POLICIES.........[OK] "
	
		echo ""
		echo "##### LOADING CONFIGURATION FILE RULES"

		
# RELEASING BITRIX 24
	$IPTABLES -I INPUT -p ALL -s erimat.bitrix24.com.br -j ACCEPT

sed 1d $CONFIG | while read i;do
IP=$(echo $i | awk '{print $1;}') 
proto=$(echo $i | awk '{print $2;}')
ports=$(echo $i | awk '{print $3;}')

if [ "${IP}" = "BRASIL" ]
then
		for j in `cat $RANGEBRASIL`; do
			$IPTABLES -A INPUT -p tcp -m multiport --dports 80,22,3306,4445,2608,48805,44276,2611,443,5060,5061,10000:20000 -s $j -j ACCEPT
                        $IPTABLES -A INPUT -p udp -m multiport --dports 80,22,3306,4445,2608,48805,44276,2611,443,5060,5061,10000:20000 -s $j -j ACCEPT
		done

elif [ "${proto}" = "all" ] || [ "${proto}" = "icmp" ]
then
	$IPTABLES -A INPUT -p ${proto} -s ${IP} -j ACCEPT

else
	$IPTABLES -A INPUT -p ${proto} -m multiport --dports ${ports} -s ${IP} -j ACCEPT
fi


done

		echo "##### CONFIGURATION FILE RULES....[OK]"
		echo ""

		echo "INITIATING FAIL2BAN"
		echo ""

		service fail2ban start

		echo "######################################"
		echo "########## FIREWALL ACTIVE  ##########"
		echo "######################################"
		echo ""

#### SPACE RESERVED TO CUSTOMIZED RULES

