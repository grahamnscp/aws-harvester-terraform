#!/bin/sh

# packages
sudo zypper refresh
sudo zypper install -y git mlocate net-tools-deprecated

# services
sudo systemctl disable apparmor.service
sudo systemctl disable firewalld.service
sudo systemctl stop apparmor.service
sudo systemctl stop firewalld.service

sudo systemctl disable swap.target
sudo swapoff -a

# password for console
echo ec2-user:yourpasswordhere | chpasswd

sudo -u ec2-user -- ssh-keygen -t rsa

# env
sudo echo "alias l='ls -latFrh'" >> /home/ec2-user/.bashrc
sudo echo "alias vi=vim"         >> /home/ec2-user/.bashrc
sudo echo "set background=dark"  >> /home/ec2-user/.vimrc
sudo echo "syntax on"            >> /home/ec2-user/.vimrc
sudo chown ec2-user:users /home/ec2-user/.vimrc
sudo echo "alias l='ls -latFrh'" >> /root/.bashrc
sudo echo "alias vi=vim"         >> /root/.bashrc
sudo echo "set background=dark"  >> /root/.vimrc
sudo echo "syntax on"            >> /root/.vimrc

