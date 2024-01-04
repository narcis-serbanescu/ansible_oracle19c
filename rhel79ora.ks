# version=RHEL8
# System bootloader configuration
bootloader --append="console=ttyS0 console=ttyS0,115200n8 no_timer_check net.ifnames=0  crashkernel=auto" --location=mbr --timeout=1 --boot-drive=vda

# Clear the Master Boot Record
zerombr

# Partition clearing information
clearpart --all --initlabel

# Use text mode install
text

# Use network installation
# url --url="http://classroom.example.com/content/rhel8.2/x86_64/dvd/"

# Use cdrom/dvdrom ISO
cdrom

# Keyboard layouts
# old format: keyboard us
keyboard --vckeymap=us --xlayouts=''

# System language
lang en_US.UTF-8

# Network information
# network --bootproto=dhcp --onboot=yes --hostname=rhel79ora --noipv6
network --bootproto=static --ip=192.168.122.126 --netmask=255.255.255.0 --gateway=192.168.122.1 --onboot=yes --hostname=rhel79ora --noipv6 --device=eth0

# Reboot when the install is finished.
reboot

# Create user

user --name=oracle --shell=/bin/bash --homedir=/home/oracle --password=oracle_rhel79ora
sshkey --username=oracle "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsqBVlO+HLnihlQeV7AkRWHdVvpQVGlRinVw5fRpa/XLJW+2foQpZeNrIU+ZEAWoni2XEHqvpAQl5WTBWDTU8V9JSbwKCKY2q1hecnpPvYZq7OaNCqLyw5MbnFnFT1l5tLmlFuordI3JffXuGIx6b+kapT9TQK/cGijrgEKwBhEJVZ1i81qcCnGoib9JQ3dlKigWL7+7GRGgVDJ4a2fNmweqWVX13xeseFu7kbLIjU90lUmZfzx42TIMVxehwfrfdp/Tuudid3xKvNgjrHooA+h7nVth+OYTeyIlvanUOR5tui2kxjROErbyj6PFZeZTtfQiPfzj8acFU== oracle@ibm.com"
# Root password
rootpw --plaintext oracle@rhel79ora

# System authorization information
auth --enableshadow --passalgo=sha512
# authselect --enableshadow --passalgo=sha512

# SELinux configuration
selinux --enforcing

# initial-setup package must be installed for firtsboot
#firstboot --enable

# Firewall
#firewall --enabled --service=ssh,httpd

# Do not configure the X Window System
skipx

# System services
#services --disabled="kdump,rhsmcertd" --enabled="sshd,rngd,chronyd,httpd"
services --disabled=network,iptables,ip6tables --enabled=NetworkManager,firewalld,sshd,httpd

# System timezone
# timezone Etc/UTC --isUtc
timezone Europe/Bucharest --utc

# Disk partitioning information
# part / --fstype="xfs" --ondisk=vda --size=10000

# LVM
ignoredisk --only-use=vda
part /boot --fstype="ext4" --size=512 --ondisk=vda
part pv.0 --fstype="lvmpv" --size=1 --grow --ondisk=vda
volgroup rootvg --pesize=4096 pv.0
logvol / --vgname=rootvg  --fstype="ext4" --size=1024 --name=rootlv
logvol /usr --vgname=rootvg --fstype="ext4" --size=4096 --name=usrlv
logvol /home --vgname=rootvg --fstype="ext4" --size=1024 --name=homelv
logvol /var --vgname=rootvg  --fstype="ext4" --size=5120 --name=varlv
# logvol /var --vgname=rootvg  --fstype="ext4" --size=8192 --name=varlv
# logvol /var/log --vgname=rootvg  --fstype="ext4" --size=2048 --name=vloglv
logvol /tmp --vgname=rootvg  --fstype="ext4" --size=7168 --name=tmplv
logvol /opt --vgname=rootvg  --fstype="ext4" --size=25600 --name=optlv
logvol swap --vgname=rootvg  --fstype=swap --size=1024 --name=paging00

%packages
bind-utils
@core
bash-completion
bc
compat-libcap1
chrony
cloud-init
curl
deltarpm
dracut-config-generic
dracut-norescue
firewalld
fontconfig-devel
geoipupdate
glibc-devel
grub2
httpd
kernel
kernel-headers
ksh
libaio-devel
libstdc++
libstdc++-devel
libXrender
libXrender-devel
lsof
mailx
make
mod_ssl
nfs-utils
openssh
openssh-server
policycoreutils
rsync
setroubleshoot-server
smartmontools
sysstat
tar
unzip
wget
# Unnecessary firmware (pulled from https://github.com/chef/bento/blob/master/http/centos-7.1)
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-biosdevname
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl105-firmware
-iwl135-firmware
-iwl1000-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-libertas-usb8388-firmware
-libertas-sd8686-firmware
-libertas-sd8787-firmware
-open-vm-tools
-open-vm-tools-desktop
-plymouth
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
%end

%post --erroronfail

# For cloud images, 'eth0' _is_ the predictable device name, since we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
NAME=eth0
DEVICE="eth0"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
PREFIX=24
IPADDR=192.168.122.126
GATEWAY=192.168.122.1
DNS1=192.168.122.1
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
EOF

cat >/etc/yum.repos.d/ftp3.repo <<EOF
[ftp3_os]
name=FTP3 OS repository
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/release_cds/RHEL-7.9-GA/Server/x86_64/os/
enabled=1
gpgcheck=0
[ftp3_supplementary]
name=FTP3 supplementary repository
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/release_cds/RHEL-7.9-GA/Server-optional/x86_64/os/
enabled=1
gpgcheck=0
[ftp3_yum_os]
name=ftp3_yum_os
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7.9/x86_64/os/
enabled=0
gpgcheck=0
[ftp3_yum_S7os]
name=ftp3_S7yum_os
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/os/
enabled=1
gpgcheck=0
[ftp3_yum_ansible29]
name=ftp3_ansible29
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/ansible/2.9/os/
enabled=1
gpgcheck=0
[ftp3_yum_rh-common]
name=ftp3_rh-common
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/rh-common/os/
enabled=1
gpgcheck=0
[ftp3-rhscl]
name=FTP3 rhscl yum repository
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/rhscl/1/os/
enabled=1
gpgcheck=0
[ftp3_yum_supplementary]
name=FTP3 supplementary yum repository
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/supplementary/os/
enabled=1
gpgcheck=0
[ftp3_yum_optional]
name=FTP3 yum optional
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/optional/os/
enabled=1
gpgcheck=0
[ftp3_yum_oracle_java]
name=FTP3 yum Oracle Java
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/oracle-java/os/
enabled=1
gpgcheck=0
[ftp3_yum_highavailability]
name=FTP3 yum highavailability
baseurl=ftp://oracle%40ro.ibm.com:oracle@ftp3.linux.ibm.com/redhat/yum/server/7/7Server/x86_64/highavailability/os/
gpgcheck=0
EOF

cat >/etc/sudoers.d/oracle <<EOF
ALL ALL=(root) NOPASSWD: ALL
EOF

%end
