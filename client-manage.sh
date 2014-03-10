#!/bin/bash
# $1=operation $2=address $3=common_name
DOMAIN=vpn.ansible.com
OPER=$1
IP=$2
CN=$3
HOSTCONFIG=/etc/ansible/hosts.add

# Use function template for use in modules:
usage ()
{
    echo "Use: "${0}" <help/add/del> <arg 2> <arg 3>"
    exit 1;
}
# Some sanity checking on input:
if [[ "${#}" -lt 3 ]]; then
    usage
elif [[ "$1" == "help" ]]; then
	usage
fi

# functions to add/remove/update
addnew ()
{
	echo $CN".vpn.ansible.com  ansible_ssh_host="$IP >> $HOSTCONFIG
}
deloldcn ()
{
	sed -i /$CN/d $HOSTCONFIG
}
deloldip ()
{
	sed -i /$IP/d $HOSTCONFIG
}
updateip ()
{
	sed -i s/$OLDIP/$IP/ $HOSTCONFIG
}
updatecn ()
{
	sed -i s/$OLDCN/$CN/ $HOSTCONFIG
}

#Sanity Check for Multiple Duplicates
dupipcount=($(cat $HOSTCONFIG | grep -v "#" | grep -v '\[' | grep $CN | awk '{print $1}' | sed s/.$DOMAIN// | wc -l ))
dupcncount=($(cat $HOSTCONFIG | grep -v "#" | grep -v '\[' | grep $IP | awk '{print $2}' | sed s/ansible_ssh_host\=// | wc -l ))

if [[ "$dupipcount" -gt 1 ]]; then
	deloldip
elif [[ "$dupcncount" -gt 1 ]]; then
	deloldcn
fi

#Evaluate action on our new host
dupip=($(cat $HOSTCONFIG | grep -v "#" | grep -v '\[' | grep $CN | awk '{print $1}' | sed s/.$DOMAIN// | sort -u ))
dupcn=($(cat $HOSTCONFIG | grep -v "#" | grep -v '\[' | grep $IP | awk '{print $2}' | sed s/ansible_ssh_host\=// | sort -u ))

if [[ "$dupip" == "$IP" ]]; then
	if [[ "$dupcn" == "$CN" ]]; then
		error=1
		#Do nothing.
	elif [[ "$dupcn" != "$CN" ]]; then
		action=1
		# update CN
	fi
elif [[ "$dupip" != "$IP" ]]; then
	if [[ "$dupcn" == "$CN" ]]; then
		action=2
		#update IP
	elif [[ "$dupcn" != "$CN" ]]; then
		action=3
		# Add New
	fi
fi

#Do some work
if [[ "$OPER" == "help" ]]; then
	usage
elif [[ "$OPER" == "del" ]]; then
	deloldcn
	deloldip
elif [[ "$OPER" == "add" ]]; then
	case $action in
	1)
		updatecn
	;;
	2) 
		updateip
	;;
	3)
		addnew
	;;
	esac
else
	echo "Please see: "${0}" help"	
	error=1
fi

if [[ "$error" != "1" ]]; then
#Import into Tower:
	awx-manage inventory_import --source=$HOSTCONFIG --inventory-name=vpntest
#Kick off ad-hoc config job against new host:
	cd /var/lib/awx/projects/confignew
	ansible-playbook -i $IP, config.yml
else
	exit 1
fi