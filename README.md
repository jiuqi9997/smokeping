# SmokePing 一键脚本

[SmokePing](https://oss.oetiker.ch/smokeping) 是由 RRDtool 的作者 Tobi Oetiker 开发的一款监控网络状态和稳定性的开源软件。使用脚本安装后，SmokePing 会定时向目标发送 TCP 数据包，并对返回值进行测量和记录，通过 RRDtool 制图程序图形化地展示在各个时段内网络的延迟、抖动和丢包率，帮助我们更清楚、更直观地了解服务器的网络状况。

本脚本会使 SmokePing 运行在 Nginx 上，为了与可能存在的其他 Web 服务共存，需要9007和9008端口，请确保它们没有被占用。

目前支持的 Linux 发行版：
```
Debian 9+
Ubuntu 18+
CentOS 7+
Amazon Linux 2
Oracle Linux 7+
```

## 安装

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```

如果出现 `command not found` 请执行 `apt-get install curl -y` 或 `yum install curl -y`。

## 配置
脚本自动为 SmokePing 进行配置，可以自行按需修改。
SmokePing 主配置文件（包括目标节点）为 `/usr/local/smokeping/etc/config`，此文件的结构及其修改请查阅相关教程，附上[示例](https://oss.oetiker.ch/smokeping/doc/smokeping_examples.en.html)。
