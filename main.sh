#!/usr/bin/env bash

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
stty erase ^?

nginx_dir="/etc/nginx"
nginx_conf_dir="/etc/nginx/conf.d"

install_packages() {
	rpm_packages="tar zip unzip openssl openssl-devel lsof git jq socat nginx crontabs make gcc rrdtool rrdtool-perl perl-core spawn-fcgi traceroute zlib zlib-devel wqy-zenhei-fonts nc"
	apt_packages="tar zip unzip openssl libssl-dev lsof git jq socat nginx cron make gcc rrdtool librrds-perl spawn-fcgi traceroute zlib1g zlib1g-dev fonts-droid-fallback netcat"
	if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		$PM update
		$INS wget curl gnupg2 ca-certificates dmidecode lsb-release
		update-ca-certificates
		echo "deb http://nginx.org/packages/$ID $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
		curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
		$PM update
		$INS $apt_packages
	elif [[ $ID == "centos" ]]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
		$INS wget curl ca-certificates dmidecode epel-release
		update-ca-trust force-enable
		$INS $rpm_packages
    elif [[ $ID == "amzn" ]]; then 
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/7/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
		$INS wget curl ca-certificates dmidecode
		update-ca-trust force-enable
		amazon-linux-extras install epel -y
		$INS https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		$INS $rpm_packages
    elif [[ $ID == "ol" ]]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
        cat > /etc/yum.repos.d/elrepo.repo <<EOF
[ol_developer_EPEL]
name=Oracle Linux Developement Packages
baseurl=http://yum.oracle.com/repo/OracleLinux/OL$releasever/developer_EPEL/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF
		$INS wget curl ca-certificates dmidecode
		update-ca-trust force-enable
		$INS $rpm_packages
		firewall-cmd --zone=public --add-port=80/tcp --permanent
		systemctl restart firewalld.service
    fi
	mkdir -p $nginx_dir
	cat > $nginx_dir/nginx.conf <<EOF
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush     on;

    keepalive_timeout  65;

    gzip  on;

    include $nginx_conf_dir/*.conf;
}
EOF
	rm -rf $nginx_conf_dir/default.conf
	systemctl enable nginx
	systemctl start nginx
	ps -ef | sed '/grep/d' | grep -q nginx || error=1
	[[ $error -eq 1 ]] && echo "Nginx 安装失败" && exit 1
}

get_info() {
	source /etc/os-release || source /usr/lib/os-release || exit 1
	if [[ $ID == "centos"  || $ID == "amzn"  || $ID == "ol" ]]; then
		PM="yum"
		INS="yum install -y"
		releasever=${VERSION: 0: 1}
	elif [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		PM="apt-get"
		INS="apt-get install -y"
	else
		exit 1
	fi
	ss -tnlp | grep -q ":9007 " && echo "需要9007端口，现已被占用" && exit 1
	ss -tnlp | grep -q ":9008 " && echo "需要9008端口，现已被占用" && exit 1
	read -rp "输入服务器名称（如 香港）:" name
	read -rp "输入服务器代号（如 HK）:" code
	read -rp "输入通信密钥（不限长度）:" sec
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
	wget $origin/tcpping-sp -O /usr/bin/tcpping-sp && chmod +x /usr/bin/tcpping-sp
	wget $origin/nginx.conf -O $nginx_conf_dir/smokeping.conf && nginx -s reload
	wget $origin/config -O /usr/local/smokeping/etc/config
	wget $origin/systemd-fcgi -O /etc/systemd/system/spawn-fcgi.service
	wget $origin/systemd-master -O /etc/systemd/system/smokeping-master.service
	wget $origin/systemd-slave -O /etc/systemd/system/smokeping-slave.service
	systemctl enable spawn-fcgi smokeping-master smokeping-slave
	sed -i 's/some.url/'$ip':9008/g' /usr/local/smokeping/etc/config
	sed -i 's/SLAVE_CODE/'$code'/g' /usr/local/smokeping/etc/config /etc/systemd/system/smokeping-slave.service
	sed -i 's/SLAVE_NAME/'$name'/g' /usr/local/smokeping/etc/config
	echo "$code:$sec" > /usr/local/smokeping/etc/smokeping_secrets.dist
	echo "$sec" > /usr/local/smokeping/etc/secret
	chmod 700 /usr/local/smokeping/etc/secret /usr/local/smokeping/etc/smokeping_secrets.dist
	chown nginx:nginx /usr/local/smokeping/etc/smokeping_secrets.dist
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

systemctl start spawn-fcgi smokeping-master smokeping-slave || error=1
[[ $error -eq 1 ]] && echo "启动失败" && exit 1

rm -rf /tmp/smokeping

echo "安装完成，页面网址：http://$ip:9008/"
echo ""
echo "注意："
echo "如有必要请在防火墙放行9008端口"
echo "请等待一会，监控数据不会立即更新"
