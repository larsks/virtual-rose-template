#!/bin/sh

# This script configures the CentOS cloud image to boot into a
# desktop environment by default. You can apply the script to an image
# using the virt-customize script:
#
#     virt-customize -a CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2 \
#       --run configure-image.sh --selinux-relabel

yum -y upgrade
yum -y install epel-release
yum config-manager --set-disabled epel --set-disabled epel-modular
yum -y install @workstation
yum -y --enablerepo=epel install xrdp
systemctl enable xrdp
systemctl set-default graphical.target

cat > /etc/firewalld/zones/public.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <service name="rdp"/>
  <service name="http"/>
  <service name="https"/>
</zone>
EOF
