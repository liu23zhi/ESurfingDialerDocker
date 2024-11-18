# 适用于广东天翼校园网的docker容器自动认证方案

**本项目并不提供任何反检测手段，如果需要，请移步至[此视频](https://b23.tv/XFgF5hd)**

**经过验证 <ins>"电子科技大学中山学院"</ins> 可用！（掌声祝贺👏）**

## 本项目基于Rsplwe大佬的项目 ☞[[传送门](https://github.com/Rsplwe/ESurfingDialer)] 和中国电信官方客户端（天翼校园）搭建的Docker镜像自动构建

**Phone版本占用手机认证通道进行网络认证**

**~~PC版本占用电脑认证通道进行网络认证~~**（PC版本已经炸了）

## Phone版本已经兼容amd64和arm64架构设备
## 随缘修复PC版本（最近不大可能会）

## 此项目利用了Github action自动拉取源码进行构建

可以尝试在使用本镜像的基础上，使用 **[watchtower](https://github.com/containrrr/watchtower "watchover")** 进行自动更新Docker镜像，确保该镜像为最新镜像。 
### 目前提供 ~~两种~~ 一种 Docker镜像；

~~1. ESurfingDockerPc~~ **（炸了）**

此镜像占用电脑认证通道进行网络认证

2. ESurfingDockerPhone **（强烈推荐！！！）**

此镜像占用手机上网资格进行网络认证

### 此外还提供免docker直接运行版本（支持Linux和windows）

1. ESurfingDialer.zip **☞[[传送门](https://github.com/liu23zhi/ESurfingDialerDocker/releases/latest)]**
**此方案占用手机认证通道进行网络认证**

~~2. ESurfingOffice.zip **☞[[传送门](https://github.com/liu23zhi/ESurfingDialerDocker/releases/latest)]**
基于中国电信官方客户端 编译而成
**此方案占用电脑认证通道进行网络认证**~~ **（都说炸了咯）**

**镜像会在编译时同时上传到Github和Docker Hub**

> **作者的话：因为电脑认证通道和手机认证通道并不冲突，所以理论上是可以实现一个账号双倍宽带速率的** | 🤣☞ **（理论上）**

# 推荐搭配openwrt&docker食用

# 如果没有合适的硬件路由器，一台x86双网口主机&虚拟机也是一个不错的选择
**要是想直接用x86主机装openwrt我也不拦着你**

>好奢侈啊（小声）

**[这里](/QWE.md)有虚拟机安装openwrt的方法**

# Docker镜像使用方法
**与Rsplwe大佬的项目相似**

>[!TIP]
>如openwrt带有docker使用ssh可按教程无脑食用

### 1. 使用ESurfingDockerPhoneDocker镜像（强烈推荐！！！）
#### 提供三种方法拉取镜像（openwrt主机有网环境&无网环境）

##### A:从<ins>Github</ins>拉取镜像（适用于openwrt主机有网环境）

>[!NOTE]
>ssh连接到openwrt主机，输入以下代码👇 **（不必带上"<>"）**

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```

>[!TIP]
>假设账号为123，密码为456，则应该执行👇

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```

##### B:从<ins>Docker Hub</ins>拉取镜像（适用于openwrt主机有网环境）

>[!NOTE]
>ssh连接到openwrt主机，输入以下代码👇 **（不必带上"<>"）**

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

>[!TIP]
>假设账号为123，密码为456，则应该执行👇

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

##### C:从<ins>本地</ins>导入镜像（适用于openwrt主机无网环境）

**（1）前往[Releases](https://github.com/liu23zhi/ESurfingDialerDocker/releases/latest)处下载最新镜像文件<ins>ESurfingDockerPhone.tar.gz</ins>**

**（2）把镜像文件以任何方式传到openwrt主机比如/tmp什么的里面（找得着就行）**

**（3）导入镜像文件**

>[!NOTE]
>ssh连接到openwrt主机，输入以下代码👇

```shell
docker load -i ESurfingDockerPhone.tar.gz
```

>[!NOTE]
>**docker load -i 后面要填写你放置ESurfingDockerPhone.tar.gz文件的位置**

>[!TIP]
>以下是镜像文件存在/tmp里时的导入示例👇

```shell
docker load -i /tmp/ESurfingDockerPhone.tar.gz
```

**（4）创建并启动容器**

>[!NOTE]
>ssh连接到openwrt主机，输入以下代码👇 **（不必带上"<>"）**

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

>[!TIP]
>假设账号为123，密码为456，则应该执行👇

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

### ~~2. 使用ESurfingDockerPc镜像~~（炸了啦）

<!--#### 任意使用以下3种之一方法拉取镜像

##### A:从Github拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```

<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```

##### B:从Docker Hub拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

##### C:（1）从Github Release下载，后本地导入（记住导入文件的位置）

[前往Release](https://github.com/liu23zhi/ESurfingDialerDocker/releases)下载ESurfingDockerPc.tar.gz

**（2）然后执行列代码导入镜像文件**

```shell
docker load -i ESurfingDockerPc.tar.gz
```
注意：
docker load -i 后面要填写你放置ESurfingDockerPhone.tar.gz文件的位置
如：文件放置在/tmp

```shell
docker load -i /tmp/ESurfingDockerPhone.tar.gz
```

**（3）然后创建并启动容器**

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
#导入镜像
docker load -i ESurfingDockerPc.tar.gz
#创建容器并启动（上面导入镜像代码完成后。再输入此代码）
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

#### [点击此查看pc运行错误代码详解](/PC.md)-->

## 以上操作完成后

**ssh连接到openwrt主机，输入以下代码👇**

```shell
docker logs -f dialer-client
```

>[!NOTE]
>如果日志输出如下，就代表网络已经成功认证
>将宿舍其他的电脑插入openwrt主机的物理LAN口就可以愉快地上网了

```shell
INFO [com.rsplwe.esurfing.Client] (Client:82) - The login has been authorized.
```

>[!WARNING]
>如果日志提示"keep.url"和"term.url"为空，则需要进行重新连接WAN口或重启docker容器等操作
