How to use this script:
=======================

REQUIREMENTS:
-------------

- Ansible/Tower installed on CentOS host (note: this could translate to Ubuntu LTS.  Tower is only supported on RHEL or CentOS 6/UbuntuLTS)
- OpenVPN installed on Tower host, working.  This also requires correct network subnets being pushed and routing for Tower to get to the VPN clients.
- All client certificates using their own unique CN (Common Name) in the OpenVPN client certs.

SETUP:
------

- Add the following lines to your server.conf for OpenVPN:

```
script-security 3 system
learn-address /etc/awx/client-manage.sh
user awx
group awx
```

- make sure that the permissions allow for the system account awx to write to /etc/ansible/hosts.vpn:

```
chown awx.awx /etc/ansible/hosts.vpn
chmod 644 /etc/ansible/hosts.vpn
```

Note: I use /etc/ansible/hosts.vpn, but it can be any file specified in the script's variable $HOSTCONFIG

- In Tower, make sure you create an inventory and use that name in the attached script as the value for $INVNAME  Leave it empty on creation.

- the file specified as $HOSTCONFIG above needs to have a group at the top line as follows:

```
[vpnclients]
```

- Copy client-manage.sh to /etc/awx and change permissions to 755:

```
cp client-manage.sh /etc/awx
chown awx.awx /etc/awx/client-manage.sh
chmod 755 /etc/awx/client-manage.sh
```

USE:
----

- Connect a client, on connect the script will be executed as the awx user, adding to both the /etc/ansible hosts inventory for command line use as well have that file imported into Tower's inventory.

- Manual use of the script:

```
$bash > ./client-manage.sh (add|delete) (IPADDRESS) (COMMON NAME)
```

- You will notice that lines 111 and 112 of the script are commented out:

```
#	cd /var/lib/awx/projects/$PROJ
#	ansible-playbook -i $IP, $PLAYBOOK
```

This is an ability to call ansible from the command line to start a bootstrap/configuration playbook (or anything you need run against the host.) This requires the awx user to be able to ssh to the client and that the client has minimum requirements met to be able to run the ansible playbook.  For example, if the playbook does not specify an ssh user or password, the awx user must have it's id_rsa.pub key copied to ~/.ssh/authorized_keys of the user it is connecting to the vpn client as.  If you do not use the raw module exclusively in your playbook connecting to your client, you must have at least python 2.5 installed on the vpnclient to use ansible modules/playbooks.

I have left this commented out because I was not using this feature.  For the basic operations of this script (add the host to the inventory) it is not needed.

This script will intelligently remove duplicate IP address with different CN names, duplicate CN names with different IP addresses, or do nothing if the host in full (CN and IP) already exist.  It can also remove old hosts on disconnect of the VPN client, assuming your VPN disconnect script properties are set in the server.conf file of OpenVPN.

Also, you can change $1 from 'add' to 'delete' and test that you can remove the host from the $HOSTCONFIG as well.

NOTE: learn-address doesn't auto-remove hosts from either /etc/ansible/hosts.vpn or from Tower (it doesn't call the script) on disconnect.  I am not sure how to fix this yet.

ALSO NOTE:  The lockfile mechanism in this script only retries once.  May need to add mulitple retries.


TROUBLESHOOTING:
----------------

- Is your client connecting properly?

Verify certificates and connections via standard OpenVPN troubleshooting.

- Is the host not added to Tower?

Verify you can manually execute this script and add to tower.  As the awx user you can execute as follows:

```
$bash > ./client-manage.sh add (IPADDRESS) (COMMON NAME)
```

NOTES:
------

- Adapted from:

```
http://openvpn.net/archive/openvpn-users/2006-10/msg00119.html
https://forums.openvpn.net/topic12613.html
```