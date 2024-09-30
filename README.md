# 这一个基于Rsplwe大佬的项目  https://github.com/Rsplwe/ESurfingDialer 和中国电信官方客户端搭建的Docker镜像自动构建项目
目前貌似只能在广东省使用。

**此项目利用了Github action自动拉取源码进行构建**

想最求最新的，可以尝试使用watchtower https://github.com/containrrr/watchtower
### 目前提供两种镜像；
1. ESurfingDockerPc
此镜像占用电脑设备上网资格进行网络认证
2. ESurfingDockerPhoneDocker
此镜像占用手机设备上网资格进行网络认证
**镜像会在编译时同时上传到Github和Docker Hub**

**有能力者，可以尝试进行双线叠加。**
## 使用方法
**与Rsplwe大佬的项目相似**
### 1.使用ESurfingDockerPhoneDocker镜像
#### (1)从Githu拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerphonedocker:latest
```

</details>

##### (2)从Docker Hub拉取镜像

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

##### (3)从Github Release下载，后本地导入

[前往Release](/releases/latest/ "Release")下载ESurfingDockerPhone.tar.gz。

执行列代码导入镜像文件
```shell
docker load -i ESurfingDockerPhone.tar.gz
```

然后创建并启动容器

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
#导入镜像
docker load -i ESurfingDockerPhone.tar.gz
#创建容器并启动
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerphonedocker:latest
```

</details>

#### 2.使用ESurfingDockerPc镜像
##### (1)从Githu拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always ghcr.io/liu23zhi/esurfingdockerpc:latest
```

</details>

##### (2)从Docker Hub拉取镜像

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

</details>

##### (3)从Github Release下载，后本地导入

[前往Release](/releases/latest/ "Release")下载ESurfingDockerPc.tar.gz。

执行列代码导入镜像文件
```shell
docker load -i ESurfingDockerPc.tar.gz
```

然后创建并启动容器

```shell
docker run -itd -e DIALER_USER=<用户名/手机号> -e DIALER_PASSWORD=<密码> --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```
<details>
<summary>使用示例</summary>

**假设账号为123，密码为456。则应该执行**

```shell
#导入镜像
docker load -i ESurfingDockerPc.tar.gz
#创建容器并启动
docker run -itd -e DIALER_USER=123 -e DIALER_PASSWORD=456 --name dialer-client --network host --restart=always xenlia/esurfingdockerpc:latest
```

</details>
