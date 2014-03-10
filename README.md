Tower-OpenVPN
=============

Scripts to connect OpenVPN clients to Tower as inventory.

This script (client-manage.sh), called by openvpn on client connect and disconnect, is
meant to add the host to an ansible/tower inventory.

NOTE: It assumes CN (common name) of the client certificate is unique.

See the INSTRUCTIONS.md for more info.

Usual caveats re: Warranty and support apply:  I am not an OpenVPN expert.  Please direct OpenVPN config issues to their support forms.  Insofar as this script: it works per advertised but may require adaptation on your end to suit your environment.