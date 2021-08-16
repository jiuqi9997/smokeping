#!/usr/bin/env bash

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
stty erase ^?

caddy_dir="/etc/caddy-sp"

install_packages() {
	rpm_packages="tar zip unzip openssl openssl-devel make gcc rrdtool rrdtool-perl perl-core spawn-fcgi traceroute zlib zlib-devel wqy-zenhei-fonts nc"
	apt_packages="tar zip unzip openssl libssl-dev make gcc rrdtool librrds-perl spawn-fcgi traceroute zlib1g zlib1g-dev fonts-droid-fallback netcat"
	if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		$PM update
		$INS wget curl ca-certificates
		$INS $apt_packages
	elif [[ $ID == "centos" ]]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		$INS wget curl ca-certificates epel-release
		update-ca-trust force-enable
		$INS $rpm_packages
	fi
}

get_info() {
	source /etc/os-release || source /usr/lib/os-release || exit 1
	if [[ $ID == "centos" ]]; then
		PM="yum"
		INS="yum install -y"
	elif [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		PM="apt-get"
		INS="apt-get install -y"
	else
		exit 1
	fi
	read -rp "输入服务器名称（如 香港）:" name
	read -rp "输入服务器代号（如 HK）:" code
	read -rp "输入通信密钥（不限长度）:" sec
	read -rp "输入监控页面端口（默认9008）：" port1
	read -rp "输入FCGI监听端口（默认9007）：" port2
	ss -tnlp | grep -q ":${port1:-9008} " && echo "端口 ${port1:-9008} 已被占用" && exit 1
	ss -tnlp | grep -q ":${port2:-9007} " && echo "端口 ${port2:-9007} 已被占用" && exit 1
}

compile_smokeping() {
	[[ -e /usr/local/smokeping ]] && rm -rf /usr/local/smokeping
	[[ -e /tmp/smokeping ]] && rm -rf /tmp/smokeping
	mkdir -p /tmp/smokeping
	cd /tmp/smokeping
	wget https://github.com/oetiker/SmokePing/releases/download/2.7.3/smokeping-2.7.3.tar.gz
	tar xzvf smokeping-2.7.3.tar.gz
	cd smokeping-2.7.3
	./configure --prefix=/usr/local/smokeping
	if type -P make && ! type -P gmake; then
		ln -s $(type -P make) /usr/bin/gmake
	fi
	make install || gmake install
	[[ ! -e /usr/local/smokeping/bin/smokeping ]] && echo "编译 SmokePing 失败" && exit 1
}

configure() {
	origin="https://github.com/jiuqi9997/smokeping/raw/main"
	ip=$(curl -sL https://api64.ipify.org -4) || error=1
	[[ $error -eq 1 ]] && echo "获取本机 IP 地址失败" && exit 1
	mkdir -p $caddy_dir
	wget $origin/Caddyfile -O $caddy_dir/Caddyfile
	wget https://github.com/caddyserver/caddy/releases/download/v2.4.3/caddy_2.4.3_linux_amd64.tar.gz -O caddy.tar.gz
	rm -rf $(tar xzvf caddy.tar.gz && cp caddy /usr/bin/caddy-sp) caddy.tar.gz
	wget $origin/tcpping-sp -O /usr/bin/tcpping-sp && chmod +x /usr/bin/tcpping-sp
	wget $origin/config -O /usr/local/smokeping/etc/config
	wget $origin/systemd-caddy -O /etc/systemd/system/caddy-sp.service
	wget $origin/systemd-fcgi -O /etc/systemd/system/spawn-fcgi.service
	wget $origin/systemd-master -O /etc/systemd/system/smokeping-master.service
	wget $origin/systemd-slave -O /etc/systemd/system/smokeping-slave.service
	sed -i 's/port1/'${port1:-9008}'/g;s/port2/'${port2:-9007}'/g' $caddy_dir/Caddyfile /etc/systemd/system/smokeping-slave.service /etc/systemd/system/spawn-fcgi.service
	sed -i 's/SLAVE_CODE/'$code'/g' /usr/local/smokeping/etc/config /etc/systemd/system/smokeping-slave.service
	systemctl daemon-reload
	systemctl enable caddy-sp spawn-fcgi smokeping-master smokeping-slave
	sed -i 's/some.url/'$ip':'${port1:-9008}'/g;s/SLAVE_NAME/'$name'/g' /usr/local/smokeping/etc/config
	echo "$code:$sec" > /usr/local/smokeping/etc/smokeping_secrets.dist
	echo "$sec" > /usr/local/smokeping/etc/secret
	chmod 700 /usr/local/smokeping/etc/secret /usr/local/smokeping/etc/smokeping_secrets.dist
	cd /usr/local/smokeping/htdocs
	mkdir -p data var cache ../cache
	mv smokeping.fcgi.dist smokeping.fcgi
	../bin/smokeping --debug || error=1
	[[ $error -eq 1 ]] && echo "测试运行失败！" && exit 1
}



get_info
install_packages
compile_smokeping
configure

systemctl start caddy-sp spawn-fcgi smokeping-master smokeping-slave || error=1
[[ $error -eq 1 ]] && echo "启动失败" && exit 1

rm -rf /tmp/smokeping

echo "安装完成，监控页面网址：http://$ip:${port1:-9008}/"
echo ""
echo "注意："
echo "如有必要请在防火墙放行 ${port1:-9008} 端口"
echo "请等待一会，监控数据不会立即更新"
