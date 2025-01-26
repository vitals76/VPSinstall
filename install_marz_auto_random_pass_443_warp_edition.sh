#!/usr/bin/env bash


systemctl disable --now unattended-upgrades

apt update -y
apt install curl net-tools iftop nload -y
apt autoremove --purge snapd -y

# Clean journal logs
journalctl --vacuum-size=5M
journalctl --verify
sed -i -e "s/#SystemMaxUse=/SystemMaxUse=5M/g" /etc/systemd/journald.conf
sed -i -e "s/#SystemMaxFileSize=/SystemMaxFileSize=1M/g" /etc/systemd/journald.conf
sed -i -e "s/#SystemMaxFiles=100/SystemMaxFiles=5/g" /etc/systemd/journald.conf
systemctl daemon-reload
systemctl restart systemd-journald
sleep 1



#### ENABLE BBRv2
enable_bbr() {
	echo -e "${blue}Enable BBR${clear}"
	if [[ ! "$(sysctl net.core.default_qdisc)" == *"= fq" ]]
	then
	    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
	fi
	if [[ ! "$(sysctl net.ipv4.tcp_congestion_control)" == *"bbr" ]]
	then
	    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
	fi
}
enable_bbr





# IP VPS
IPVPS=`ip addr show $ETH | grep global | sed -En -e 's/.*inet ([0-9.]+).*/\1/p' | head -n1`


# Download env and fix pass.
cd /root/
curl -sL "https://checkvpn.net/files/.env.example" -o .env.example
cp -r .env.example env_marzban


# random password with 16 symbols
PASSMARZBAN=`openssl rand -hex 16`

# random port from 
RANDPORT=`echo $(( ( RANDOM % 65535 )  + 1025 ))`


sed -i '2d' env_marzban
sed -i -e '1iUVICORN_PORT = "'$RANDPORT'"  ' env_marzban
sed -i -e '1iSUDO_PASSWORD = "'$PASSMARZBAN'"  ' env_marzban
sed -i -e '1iSUDO_USERNAME = "vitals"  ' env_marzban





# install marzban  with fixed .env
bash -c "$(curl -sL https://checkvpn.net/files/marzban2.sh )" @ install v0.6.0



### WARP INSTALL on UBUNTU -  127.0.0.1:40000
#docker run --restart=always -itd --name warp_socks_v3 -p 127.0.0.1:40000:9091 monius/docker-warp-socks:v3

docker run --restart=always --log-driver none -itd --name warp_socks_v3 -p 127.0.0.1:40000:9091 gnixua/docker-warp-socks-backup:v3





sleep 1
echo "------------------------------------------"
echo "WEB interface Marzban IP: http://"$IPVPS":"$RANDPORT"/dashboard/login"
echo "WEB interface Marzban login: vitals"
echo "WEB interface Marzban password:" $PASSMARZBAN



