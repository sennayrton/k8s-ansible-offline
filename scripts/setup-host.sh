#!/bin/bash
# Finalmente se ha optado por hacer todo esto en un playbook (/roles/common/tasks/setup.yaml) para automatizarlo mejor
# Script para configurar rápidamente las máquinas: IP, hostame, usuario, grupo, home, permisos sobre /usr/local/pr/kamino, layout teclado, prompt y bashrc

###############
## Variables ##
###############

ENTORNO=pr # pr para PRO, ei para INT y DEV
NODO=hostname #hostname: master, worker...
USER=xpkami01
GROUP=gpkami01
PASS=M1gr4c10n!
USER_DIR=/usr/local/$ENTORNO/$USER
UUID_LINE=$(uuidgen ens192)

###############
### Tareas ####
###############

mkdir -p $USER_DIR

# Customize .bashrc
cat <<EOF >> $USER_DIR/.bashrc
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -la'
alias k='kubectl'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

export PS1="🔱⛵\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
export http_proxy=http://10.200.140.230:80
export https_proxy=http://10.200.140.230:80

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

EOF

# Load .bashrc at user login
echo "source ~/.bashrc" > $USER_DIR/.profile

# Create group and user
groupadd $GROUP
useradd $USER -g $GROUP -d $USER_DIR
echo $PASS | passwd $USER --stdin
chown -R $USER:$GROUP $USER_DIR

# Optional : add group to sudoers
echo "%$GROUP ALL=(ALL) ALL" >> /etc/sudoers

# Optional : do not restrict PATH variable for sudo. Allows to do 'sudo <command>' for executables in /usr/local/bin
sed -i '/^[^#]/ s/\(^.*secure_path.*$\)/#\1/' /etc/sudoers

# Layout de teclado en espanol
localectl set-keymap es

# Set hostname and IP
hostnamectl set-hostname $NODO

#cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ens192
#TYPE=Ethernet
#PROXY_METHOD=none
#BROWSER_ONLY=no
#BOOTPROTO=none
#DEFROUTE=yes
#IPV4_FAILURE_FATAL=no
#IPV6INIT=yes
#IPV6_AUTOCONF=yes
#IPV6_DEFROUTE=yes
#IPV6_FAILURE_FATAL=no
#IPV6_ADDR_GEN_MODE=stable-privacy
#NAME=ens192
#UUID=$UUID_LINE
#DEVICE=ens192
#ONBOOT=yes
#IPADDR=$IP
#PREFIX=24
#GATEWAY=192.168.112.254
#DNS1=192.168.131.11
#IPV6_PRIVACY=no
#EOF

cat <<EOF > /etc/hosts
# 192.168.112.183 rke2-server1

EOF

#systemctl restart network.service

reboot
