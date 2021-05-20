# SmokePing 一键脚本

SmokePing 是由 rrdtool 的作者开发的一款监控网络状态和稳定性的开源软件。SmokePing 会向目标设备和系统发送各种类型的测试数据包，并对其进行测量和记录，通过 rrdtool 制图方式图形化地展示网络的延迟情况，进而帮助我们清楚、更直观地了解监控机和目标之间短期和长期的网络状况。

用法：

```
bash -c "$(curl -L https://github.com/jiuqi9997/smokeping/raw/main/main.sh)"
```

如果出现 `command not found` 请执行 `apt-get install -y` 或 `yum install curl -y`。
