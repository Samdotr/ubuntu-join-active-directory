#!/bin/bash

DOMAIN="yourdomain.name"

# join this machine to our ad

# install required packages - ubuntu 20.04
echo "Installing required packages"
echo ""
apt -y install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

# check that the machine can see the domain
echo "Checking domain availability for $DOMAIN"
echo ""
realm discover $DOMAIN

# joining the domain
echo "Attempting to join $DOMAIN"
echo ""
realm join $DOMAIN

# copying the common-session settings
echo "Updating the common-session preferences"
echo ""
cp common-session /etc/pam.d/common-session

# copying the sssd settings
echo "Updating sssd.conf preferences"
echo ""
cp sssd.conf /etc/sssd/sssd.conf

# restart the sssd service
echo "Restarting SSSD service via systemd"
echo ""
systemctl restart sssd

echo "Optional - copying a HTTPS MITM certificate"
echo ""
cp mitm.crt /usr/share/ca-certificates/local/mitm.crt

echo "Reconfiguring certificates - enable the new certificate here"
echo "Wait 5 seconds"
sleep 5
dpkg-reconfigure ca-certificates

# enable proxy via network-manager
echo "Optional - enabling the proxy via pac file"
bash -c "echo >> /etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection"
bash -c "echo [proxy] >> /etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection"
bash -c "echo method=1 >> /etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection"
bash -c "echo pac-url=http://10.1.0.1/proxy.pac >> /etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection"
