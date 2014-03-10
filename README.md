Tower-OpenVPN
=============

Scripts to connect OpenVPN clients to Tower as inventory.

This script (client-manage.sh), called by openvpn on client connect and disconnect, is
meant to add the host to an ansible/tower inventory.

NOTE: It assumes CN (common name) of the client certificate is unique.
