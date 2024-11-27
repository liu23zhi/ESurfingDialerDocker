# 解决openwrt搭配docker运行认证程序时报No route to host错误导致断网的问题

## No route to host报错原因（如不想看可以跳过此节）

顾名思义，没有到主机的路由，问题可能会出现在运营商服务器，学校路由器，客户端这三个地方

### 排查

运营商服务器和学校路由器十有八九是没有问题的，因为其他宿舍并没有出现这种情况，那么问题只能出现在客户端方面了
网上查找资料，发现No route to host报错多半是因为系统防火墙的原因导致的
所以尝试在openwrt的防火墙设置中把认证的端口放行
观察了三天，没有再出现No route to host报错和断网
所以证实了是openwrt防火墙导致的程序报错

## 解决措施

### 一、查找学校认证的端口

>[!WARNING]
>强调一下，因为不确定其他学校的认证端口是否相同，所以这一步骤是必须的

使用ssh连接到openwrt主机并输入以下指令查看docker日志👇


```shell
docker logs dialer-client 2>&1 | grep Url
```
>[!WARNING]
>至少运行一次docker并且连接到openwrt主机的设备都正常联网之后再输入该指令

>[!TIP]
>"dialer-client"是存有认证程序的docker容器的默认名称，按实际情况填写

这样会得到一大把关于**认证Url、Keep Url和Term Url**的信息

可以摘取到以下信息

![image](/images/Url.png)

其中**enet.10000.gd.cn:10001**的**10001**端口

和**14.146.227.142:7001/keep.cgi**的**7001**端口

还有**14.146.227.141:7001/term.cgi**的**7001**端口

就是我们要找的端口

>[!WARNING]
>再次强调，10001和7001是作者所在学校的认证端口，不确定其他学校的认证端口是否相同，以实际情况为准

>[!TIP]
>Keep Url和Term Url的端口多半是一样的

### 二、在openwrt防火墙放行端口

>[!NOTE]
>根据固件实际情况操作，不过都大差不差，本文使用的是Argon主题的openwrt固件

1. 按照途中序号顺序戳按钮

![image](/images/Port1.png)

2. 在这个页面下滑找到 **"打开路由器端口"** 字样

![image](/images/Port2.png)

3. 在 **"外部端口"** 处填入刚刚获取到的端口（要放行多少个端口就填多少次）并添加规则

>[!TIP]
>如下图所示即为添加成功（别忘了保存&应用）

![image](/images/Port3.png)

>[!WARNING]
>第三次强调，端口可能不一样，以实际情况为准

### 三、Enjoy your network

做完这些步骤之后，不会再发生No route to host报错（至少截至本文写完的时间都没复现）
