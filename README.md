# SmokePing 一键脚本

SmokePing 是由 rrdtool 的作者开发的一款监控网络状态和稳定性的开源软件。SmokePing 会向目标设备和系统发送各种类型的测试数据包，并对其进行测量和记录，通过 rrdtool 制图方式图形化地展示网络的延迟情况，进而帮助我们清楚、更直观地了解监控机和目标之间短期和长期的网络状况。

本项目旨在使 SmokePing 运行在 Nginx 上而非大部分教程指导的运行在 Apache 2 上，在方便未安装 Web 服务的系统简单快速地部署 SmokePing 进行监控的同时也为希望在 Nginx 上实现 SmokePing 前端输出的想法提供参考。

目前支持 Amazon Linux 2 (AMI), CentOS 7 及以上、Debian 9 及以上、Oracle Linux 7 及以上和 Ubuntu 18 及以上。

**注：** Deb 系的中文支持依赖 `fonts-droid-fallback`，目前已经解决；红帽系由于前述问题目前无法输出中文，欢迎提出 PR。

## 用法：

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```

如果出现 `command not found` 请执行 `apt-get install curl -y` 或 `yum install curl -y`。

## 配置：
SmokePing 主配置文件（包括目标节点）为 `/usr/local/smokeping/etc/config`，此文件的结构及其修改请查阅相关教程。
