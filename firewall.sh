#!/bin/bash

RANGEBRASIL="/usr/RANGE_BRASIL"
CONFIG="/usr/firewall.conf"
IPTABLES=/sbin/iptables
	
		service fail2ban stop

		echo ""
		echo "#######################################"
		echo "########## FIREWALL ERIX 2.0 ##########"
		echo "#######################################"
		echo ""

# Limpar Tabela
		# Limpa todas as Rules em todas as tabelas
		$IPTABLES -t filter -F
		$IPTABLES -t nat -F
		$IPTABLES -t mangle -F
		# Remove todas as Chains em todas as tabelas
		$IPTABLES -t filter -X
		$IPTABLES -t nat -X
		$IPTABLES -t mangle -X
		#Zera todos os contadores de todas as Chains em todas as tabelas
		$IPTABLES -t filter -Z
		$IPTABLES -t nat -Z
		$IPTABLES -t mangle -Z
		echo ""
		echo "##### ZERANDO TODAS AS REGRAS..............[OK]"
# Carrega os modulos
		modprobe ip_tables
		modprobe iptable_filter
		modprobe iptable_mangle
		modprobe iptable_nat
		modprobe ipt_MASQUERADE

#libera ping no kernel, pode ser trocado o valor para 1 para desabilitar o ping
		echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

#estabelece syn_cookie para evitar ataque de syn_flood
		echo "1" > /proc/sys/net/ipv4/tcp_syncookies

# Protege contra IP spoofing:
		echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Descarta pacotes malformados, protegendo contra ataques diversos:
		$IPTABLES -I INPUT -m state --state INVALID -j DROP
		
# Libera loopback e conexoes iniciadas pelo servidor
		$IPTABLES -I INPUT -d 127.0.0.1 -j ACCEPT
		$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
		$IPTABLES -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		
		echo ""
		echo "##### CARREGANDO POLITICAS PADRAO DAS TABELAS"
		
		
# Define a poli­tica DEFAULT das TABELAS
		$IPTABLES -P INPUT DROP
		$IPTABLES -P OUTPUT ACCEPT
		$IPTABLES -P FORWARD DROP

		echo "##### POLITICAS PADRAO DAS TABELAS.........[OK] "
	
		echo ""
		echo "##### CARREGANDO REGRAS DO ARQUIVO DE CONFIGURACAO"

		
# LIBERANDO BITRIX 24
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

		echo "##### REGRAS DO ARQUIVO DE CONFIGURACAO....[OK]"
		echo ""

		echo "INICIANDO FAIL2BAN"
		echo ""

		service fail2ban start

		echo "######################################"
		echo "########## FIREWALL ATIVADO ##########"
		echo "######################################"
		echo ""

#### ESPACO RESERVADO A REGRAS CUSTOMIZADAS
