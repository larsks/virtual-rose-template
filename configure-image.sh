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
