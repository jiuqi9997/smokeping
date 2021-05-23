# SmokePing 一键脚本

[SmokePing](https://oss.oetiker.ch/smokeping) 是由 [RRDtool](https://oss.oetiker.ch/rrdtool) 的作者 [Tobi Oetiker](https://www.oetiker.ch) 开发的一款监控网络状态和稳定性的开源软件。SmokePing 会不断向目标发送各种类型的数据包，并对返回值进行测量和记录，通过 RRDtool 制图程序图形化地展示在各个时段内网络的延迟和丢包情况，帮助我们更清楚、更直观地了解监控机和监控目标之间短期和长期的网络状况。

本项目旨在使 SmokePing 运行在 [Nginx](https://nginx.org) 上而非大部分教程指导的运行在 [Apache 2](https://httpd.apache.org) 上，方便在未安装 Web 服务的系统上简单快速地部署 SmokePing 进行监控的同时也为希望在 Nginx 上实现 SmokePing 前端输出的想法提供参考。

目前支持 [Amazon Linux 2 (AMI)](https://aws.amazon.com/amazon-linux-2), [CentOS 7](https://www.centos.org) 及以上、[Debian 9](https://www.debian.org) 及以上、[Oracle Linux 7](https://www.oracle.com/linux) 及以上和 [Ubuntu 18](https://ubuntu.com) 及以上的 Linux 发行版。


## 用法

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```

如果出现 `command not found` 请执行 `apt-get install curl -y` 或 `yum install curl -y`。

## 常见问题
### `epel/x86_64` 错误
常见于 Amazon Linux 2 (AMI)，因 AWS 与 fedoraproject.org 之间随机存在连通性问题，而 Amazon Linux 2 官方指导[\[1\]](https://aws.amazon.com/cn/premiumsupport/knowledge-center/ec2-enable-epel)[\[2\]](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/add-repositories.html)中指示使用 `amazon-linux-extras install epel -y` 命令或 `yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm` 命令安装的 ELRepo 源均以 fedoraproject.org 为 Baseurl 或 Metalink 终结点。
**解决方案：** 更换非 Amazon Linux 2 系统。
### 中文显示异常
常见于 Debian 或 Ubuntu，可能因系统精简掉了中文字体。
**解决方案：** 执行 `apt-get install -y wqy-zenhei-fonts`。

## SmokePing 配置
SmokePing 主配置文件（包括目标节点）为 `/usr/local/smokeping/etc/config`，此文件的结构及其修改请查阅相关教程，附上[官方 Examples](https://oss.oetiker.ch/smokeping/doc/smokeping_examples.en.html)。
