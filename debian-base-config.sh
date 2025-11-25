
# This script contains many handy settings

# SSH (allow for root login and disable r-DNS check)
  
# Below line can be replaced with manual action:
#           Open /etc/ssh/sshd_config, find line starting with PermitRootLogin
#           and modify it (or add) to be "PermitRootLogin yes"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

sed -ie "s/^PermitRootLogin/#PermitRootLogin/g" /etc/ssh/sshd_config && echo -e "\nPermitRootLogin yes" >> /etc/ssh/sshd_config
sed -ie "s/^UseDNS/#UseDNS/g" /etc/ssh/sshd_config && echo -e "\nUseDNS no\n" >> /etc/ssh/sshd_config
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 2880" >> /etc/ssh/sshd_config
systemctl restart ssh.service

# Configure proxy if needed
# echo 'Acquire::http::Proxy "http://172.16.1.253:3128";' > /etc/apt/apt.conf.d/02proxy
# echo 'Acquire::http::Proxy "http://172.27.16.253:3128";' > /etc/apt/apt.conf.d/02proxy

# Install/remove some packages

[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && apt-get --purge -y remove os-prober || echo "Not VMWare, skipping..."

apt-get --purge -y remove rsyslog && apt-get update && apt-get -y install acl bootlogd bzip2 apt-transport-https curl dnsutils htop iftop iotop iptraf less links lsb-release lynx man mc ncdu net-tools psmisc screen sudo sysstat tcpdump telnet traceroute tshark unzip zip lsof socat gnupg2 wget syslog-ng vlan jq figlet toilet

[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && apt-get -y install open-vm-tools || (echo "Not VMWare, skipping VM Tools..." && apt-get -y install ifenslave)


# Disable console cleanup after boot and enable verbose init
cp /lib/systemd/system/getty@.service /lib/systemd/system/getty@.service.old
sed -ie "s/^TTYVTDisallocate=yes$/TTYVTDisallocate=no/" /lib/systemd/system/getty@.service

sed -ie "s/^\(GRUB_CMDLINE.*\)quiet\(.*\)$/\1\2/g" /etc/default/grub

# Disable IPv6

sed -ie "s/^\(GRUB_CMDLINE.*\)ipv6.disable=[0|1]\(.*\)$/\1\2/g" /etc/default/grub && \
sed -ie "s/^\(GRUB_CMDLINE_LINUX=\"\)[ ]*\(.*\)$/\1ipv6.disable=1 \2/g" /etc/default/grub && \
sed -i 's/[ ]*"/"/g' /etc/default/grub && \
sed -i 's/[ ][ ]*/ /g' /etc/default/grub

echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/00-ipv6-disable.conf && \
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/00-ipv6-disable.conf
 
# Make dmesg quiet
 
echo -e "@reboot\troot\tdmesg --console-off" > /etc/cron.d/dmesg-quiet

# Change ls timestamps to ISO

echo "export TIME_STYLE=full-iso" > /etc/profile.d/time-style.sh
chmod 775 /etc/profile.d/time-style.sh


> /etc/profile.d/aliases.sh 

echo "alias historyoff='set +o history'" >> /etc/profile.d/aliases.sh 
echo "alias historyon='set -o history'" >> /etc/profile.d/aliases.sh
echo "alias ll='ls -lh'" >> /etc/profile.d/aliases.sh 
echo "alias lla='ls -lha'" >> /etc/profile.d/aliases.sh 
echo "alias ssu='sudo su -'" >> /etc/profile.d/aliases.sh 
echo alias ver=\'lsb_release -a \| sed \"s/^\\\(Release.*\\\)$/\\1 \($\(cat /etc/debian_version\)\)/g\"\' >> /etc/profile.d/aliases.sh

chmod 775 /etc/profile.d/aliases.sh

# Get rid of some welcome messages
 
> /etc/issue
> /etc/issue.net

apt install figlet toilet -y && echo " $(hostnamectl hostname | tr '[:lower:]' '[:upper:]') " | toilet -f big -F border -w 1000 | tee /etc/motd
 
# Get rid of some error messages
  
echo "blacklist floppy" > /etc/modprobe.d/floppy.conf

[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && (echo "blacklist i2c_piix4" > /etc/modprobe.d/smbus.conf) || echo "Not VMWare, skipping..."
[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && (find /sys -name *max_write_same_blocks -exec echo w {} - - - - 0 \; > /etc/tmpfiles.d/max_write_same_blocks.conf) || echo "Not VMWare, skipping..."

# Remove not needed packages

apt autoremove --purge -y && apt purge ~c -y && apt clean

# Refresh GRUB
 
depmod -a && update-initramfs -u && update-grub2
