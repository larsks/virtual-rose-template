#!/bin/bash

# This script configures the CentOS cloud image to boot into a
# desktop environment by default. You can apply the script to an image
# using the virt-customize script:
#
#     virt-customize -a image.qcow2 \
#       --run configure-image.sh --selinux-relabel

set -e

exec > /root/config.log 2>&1

if [ -b /dev/sda ]; then
	DEV=/dev/sda
elif [ -b /dev/vda ]; then
	DEV=/dev/vda
else
	exit 1
fi

growpart $DEV 5
btrfs filesystem resize max /

yum -y upgrade
yum -y install @workstation-product-environment
yum -y install xrdp
systemctl enable xrdp

grub2-mkconfig -o /boot/grub2/grub.cfg

cat > /etc/firewalld/zones/public.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm you
 computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <service name="rdp"/>
  <service name="http"/>
  <service name="https"/>
</zone>
EOF
