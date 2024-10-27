# 本docker镜像适用于广东地区使用天翼校园上网的方案

# 经过验证 电子科技大学中山学院 可用

># 本项目Phone版本是指占用手机资格进行连接，不是用于手机上的。pc版本是占用电脑上网资格。pc和phone都可拉取使用，目前推荐使用phone



# 这一个基于Rsplwe大佬的项目  https://github.com/Rsplwe/ESurfingDialer 和中国电信官方客户端（天翼校园）搭建的Docker镜像自动构建项目
目前貌似只能在广东省使用。

## **目前PC版本只支持amd64架构，目前正在努力兼容Arm64架构中**。

## Phone版本已经兼容amd64和arm64了

# PC版本存在严重BUG，正在修复，请勿使用

**此项目利用了Github action自动拉取源码进行构建**

可以尝试在使用本镜像的基础上，使用 [watchover](https://github.com/containrrr/watchtowe "watchover") 进行自动更新Docker镜像，确保该镜像为最新镜像。 
### 目前提供两种Docker镜像；
1. ESurfingDockerPc（目前兼容性不好）
此镜像占用电脑设备上网资格进行网络认证

2. ESurfingDockerPhoneDocker（目前推荐使用）
此镜像占用手机设备上网资格进行网络认证

### 此外还提供免docker直接运行版本（支持Linux和windows）
1. ESurfingDialer.zip（[前往Release下载](https://github.com/liu23zhi/ESurfingDialerDocker/releases)）
基于Rsplwe大佬的项目  https://github.com/Rsplwe/ESurfingDialer 编译而成。
**此方案占用手机设备上网资格**进行网络认证。

~~2. ESurfingOffice.zip（[前往Release下载](/releases/latest/ "Release")）
基于中国电信官方客户端 编译而成。
此方案占用电脑设备上网资格进行网络认证。~~（我还没写好呢！）

**镜像会在编译时同时上传到Github和Docker Hub**

**有能力者，可以尝试进行双线叠加。**~~*不建议使用OpenWrt进行叠加，因为我尝试了很多很多次，都没成功。*~~
# 这里有[虚拟机安装openwrt](/QWE.md)的方法
# Docker镜像使用方法
**与Rsplwe大佬的项目相似**

### ***openwrt带有docker使用ssh可按教程无脑食用*** 

### 1.使用ESurfingDockerPhoneDocker镜像（推荐使用）
#### 任意使用以下3种之一方法拉取镜像

##### A:从Githu拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```

</details>

##### B:**从Docker Hub**拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

</details>

##### C:（1）从Github Release下载，后本地导入（记住导入文件的位置）

[前往Release](https://github.com/liu23zhi/ESurfingDialerDocker/releases)下载ESurfingDockerPhone.tar.gz。

**（2）执行列代码导入镜像文件**

```shell
docker load -i ESurfingDockerPhone.tar.gz
```

注意：
docker load -i 后面要填写你放置ESurfingDockerPhone.tar.gz文件的位置
如：文件放置在/tmp

```shell
docker load -i /tmp/ESurfingDockerPhone.tar.gz
```

**（3）然后创建并启动容器**

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```
<details>
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
#导入镜像
docker load -i ESurfingDockerPhone.tar.gz
#创建容器并启动（上面导入镜像代码完成后。再输入此代码）
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

</details>

### 2.使用ESurfingDockerPc镜像（目前不推荐使用这个）

#### 任意使用以下3种之一方法拉取镜像

##### A:从Githu拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```
<details>
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```

</details>

##### B:从Docker Hub拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```
<details>
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

</details>

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
<details>
<summary>使用示例</summary>
**假设账号为123，密码为456。则应该执行(一定要把＜＞去掉)**

```shell
#导入镜像
docker load -i ESurfingDockerPc.tar.gz
#创建容器并启动（上面导入镜像代码完成后。再输入此代码）
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

</details>

#### [点击此查看pc运行错误代码详解](/PC.md)

## 以上两种镜像选择任意一个操作完成后

#### **输入**

```shell
docker logs -f dialer-client
```
如果显示出以下信息代表成功了
```shell
INFO [com.rsplwe.esurfing.Client] (Client:82) - The login has been authorized.
```



## 所有弄完后把网线插入软路由的LAN口就可以上网













