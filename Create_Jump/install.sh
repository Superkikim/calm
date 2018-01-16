#!/bin/bash

#================================================================
# HEADER
#================================================================
#%
#% DESCRIPTION
#%    This script is ment to be used in a Calm CentOS deployment
#%    This script allows to secure a Linux virtual machine. It will prevent ssh
#%    connection with password, or with root user, create a new user which will
#%    have sudo access, with his own private key.
#%    The ssh port 22 will be closed ans replaced by <sshport>
#%    ssh port could be hard coded in the script if you don't want to be able
#%    to chose it at deployment time
#%
#% VARIABLES
#%    This script assumes the following variables are setup in the Calm
#%    Application Profile
#%
#%    <username>        New administrator name.                 runtime
#%    <rootpassword>    New root password               secret
#%    <sshport>         New ssh port                            runtime
#%    <userkey>         New administrator public key    secret  runtime
#%    <sshgroup>        New
#%
#% AUTHOR
#%    Akim Sissaoui akim.sissaoui@nutanix.com https://akim.sissaoui.com
#================================================================
# END_OF_HEADER
#================================================================

# The set -ex command forces the script to exit if a command return a non-zero
# exit code (meaning an error happened)
set -ex

# Set hostname
hostnamectl set-hostname @@{name}@@

# Change root Password
echo '@@{rootpassword}@@' | passwd root --stdin

# Create new user
useradd @@{username}@@

# Create ssh group
groupadd @@{sshgroup}@@

# add new user to ssh group
usermod -aG @@{sshgroup}@@ @@{username}@@

# add public ssh key for new user
mkdir /home/@@{username}@@/.ssh
chmod 0700 /home/@@{username}@@/.ssh
echo '@@{userkey}@@' > /home/@@{username}@@/.ssh/authorized_keys
chmod 0600 /home/@@{username}@@/.ssh/authorized_keys
chown @@{username}@@:@@{username}@@ /home/@@{username}@@/.ssh -R

# Reconfigure sshd to use port @@{sshport}@@ instead of 22
sed -i 's/#Port 22/Port @@{sshport}@@/g' /etc/ssh/sshd_config

# Disable ssh root login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Disable ssh password authentication
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Allow only members of ssh group to login using ssh
echo 'AllowGroups @@{sshgroup}@@' >> /etc/ssh/sshd_config

# Close port 22 and open @@{sshport}@@ on firewall
iptables -D IN_public_allow -p tcp -m tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
iptables -I IN_public_allow -p tcp -m tcp --dport @@{sshport}@@ -m conntrack --ctstate NEW -j ACCEPT

# Install semanage
yum install policycoreutils-python -y

# Allow port @@{sshport}@@ in selinux
selinux_port="$(semanage port -a -t ssh_port_t -p tcp @@{sshport}@@ 2>&1 > /dev/null)"

# If command fail, return semanage error message for troubleshooting
if [ ! -z "$selinux_port" ]
then
  echo $selinux_port
  exit 1
fi

# Restart ssh
# Create sudo file for new user
# We add command alias that we will block preventing users to run interactive
# shells or to switch to root. This garantees tracking of user activity
# The line starting with username indicates the user will be able to run any
# command without password only from localhost and except commands in NSHELLS
# and NSU alliases
cat > /etc/sudoers.d/@@{username}@@ <<EOL
Cmnd_Alias NSHELLS = /bin/sh, /bin/bash, /sbin/nologin, /bin/tcsh, /bin/csh, /bin/zsh, /bin/ksh, /usr/sbin/visudo
Cmnd_Alias NSU = /bin/su
@@{username}@@ `hostname` = NOPASSWD:ALL, !NSHELLS, !NSU
EOL

# Restart SSH server
service sshd restart

# Check ssh status to review in deployment logs
service sshd status
