# SmokePing 一键脚本

[SmokePing](https://oss.oetiker.ch/smokeping) 是由 [RRDtool](https://oss.oetiker.ch/rrdtool) 的作者 [Tobi Oetiker](https://www.oetiker.ch) 开发的一款监控网络状态和稳定性的开源软件。SmokePing 会向目标设备和系统发送各种类型的测试数据包，并对其进行测量和记录，通过 RRDtool 制图方式图形化地展示网络的延迟情况，进而帮助我们清楚、更直观地了解监控机和目标之间短期和长期的网络状况。

本项目旨在使 SmokePing 运行在 [Nginx](https://nginx.org) 上而非大部分教程指导的运行在 [Apache 2](https://httpd.apache.org) 上，在方便未安装 Web 服务的系统简单快速地部署 SmokePing 进行监控的同时也为希望在 Nginx 上实现 SmokePing 前端输出的想法提供参考。

目前支持 [Amazon Linux 2 (AMI)](https://aws.amazon.com/amazon-linux-2), [CentOS 7](https://www.centos.org) 及以上、[Debian 9](https://www.debian.org) 及以上、[Oracle Linux 7](https://www.oracle.com/linux) 及以上和 [Ubuntu 18](https://ubuntu.com) 及以上的 Linux 发行版。


## 用法：

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```

如果出现 `command not found` 请执行 `apt-get install curl -y` 或 `yum install curl -y`。

## 配置：
SmokePing 主配置文件（包括目标节点）为 `/usr/local/smokeping/etc/config`，此文件的结构及其修改请查阅相关教程。
