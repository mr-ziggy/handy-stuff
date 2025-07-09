
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

# Install/remove some packages

[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && apt-get --purge -y remove os-prober || echo "Not VMWare, skipping..."

apt-get --purge -y remove rsyslog && apt-get update && apt-get -y install acl bootlogd bzip2 apt-transport-https curl dnsutils htop iftop iotop iptraf less links lsb-release lynx man mc ncdu net-tools psmisc screen sudo sysstat tcpdump telnet traceroute tshark unzip zip lsof socat gnupg2 wget syslog-ng vlan jq

[ $(dmidecode -s system-manufacturer | grep -c "^VMware") == "1" ] && apt-get -y install open-vm-tools || (echo "Not VMWare, skipping VM Tools..." && apt-get -y install ifenslave)
