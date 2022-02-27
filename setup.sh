#!/bin/bash
# Script to setup the new system
# sudo ./setup.sh
timedatectl set-timezone Asia/Kolkata
apt-get install -y vim nfs-common iftop

echo 'editprem ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/editprem
echo 'Port 1122' >> /etc/ssh/sshd_config.d/myssh.conf
echo 'AddressFamily inet' >> /etc/ssh/sshd_config.d/myssh.conf
echo 'UsePAM no' >> /etc/ssh/sshd_config.d/myssh.conf
sed -i 's/AcceptEnv/# AcceptEnv/' /etc/ssh/sshd_config
echo 'set showmatch' >> /etc/vim/vimrc.local
echo 'set ignorecase' >> /etc/vim/vimrc.local
echo 'set mouse=a' >> /etc/vim/vimrc.local
echo 'set autoindent' >> /etc/vim/vimrc.local
echo 'set smartindent' >> /etc/vim/vimrc.local
echo 'set number' >> /etc/vim/vimrc.local
echo 'set backspace=indent,eol,start' >> /etc/vim/vimrc.local
sed -i 's/APT::Periodic::Update-Package-Lists "1"/APT::Periodic::Update-Package-Lists "0"/' /etc/apt/apt.conf.d/20auto-upgrades
sed -i 's/APT::Periodic::Unattended-Upgrade "1"/APT::Periodic::Unattended-Upgrade "0"/' /etc/apt/apt.conf.d/20auto-upgrades

systemctl restart ssh.service

# Remove snapd completely
systemctl stop snapd
umount /snap/lxd
umount /snap/core20
umount /snap/snapd
apt remove --purge --assume-yes snapd
rm -rf /root/snap
rm -rf /snap
rm -rf /var/lib/snapd
rm -rf /var/cache/snapd
rm -rf /var/snap
