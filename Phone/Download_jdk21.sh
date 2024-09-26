name: 每日构建

on:
  schedule:
    - cron:  '0 8 * * *'  # 东八区每天凌晨 00:00 UTC+8 触发
  workflow_dispatch:  # 允许手动触发

permissions:
  contents: write
  discussions: write
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest  # 在最新的 Ubuntu 环境中运行

    steps:
    - name: 检出代码
      uses: actions/checkout@v4
      with:
        path: '${{ github.workspace }}'

    - name: 生成时间戳
      id: timestamp
      run: echo "TIMESTAMP=$(date +'%Y.%m.%d.%H.%M.%S')" >> $GITHUB_ENV

    - name: 检查当前目录
      run: |
        ls -l ${{ github.workspace }}

    - name: 检出ESurfingDialer代码
      uses: actions/checkout@v4
      with:
        repository: 'Rsplwe/ESurfingDialer'
        path: '${{ github.workspace }}/ESurfingDialer'

    - name: 检查ESurfingDialer目录
      run: |
        ls -l ${{ github.workspace }}/ESurfingDialer

    - name: 设置 JDK 20
      uses: actions/setup-java@v4
      with:
        java-version: '20'
        distribution: 'zulu'

    - name: 检查JDK设置
      run: |
        java -version

    - name: 进入ESurfingDialer目录并执行构建
      run: |
        cd ${{ github.workspace }}/ESurfingDialer
        ./gradlew shadowJar

    - name: 检查ESurfingDialer构建产物
      run: |
        ls -l ${{ github.workspace }}/ESurfingDialer/build/libs

    - name: 上传ESurfingDialer的JAR构建产物
      uses: actions/upload-artifact@v3
      with:
        name: ESurfingDialer的JAR构建产物
        path: '${{ github.workspace }}/ESurfingDialer/build/libs/*'

    - name: 查找最新构建的Jar文件并复制
      run: |
        chmod +x ${{ github.workspace }}/FindLasterBuildJar.sh
        ${{ github.workspace }}/FindLasterBuildJar.sh

    - name: 检查Jar文件复制结果
      run: |
        ls -l ${{ github.workspace }}/Phone

    - name: 检出Oracle-Docker-images代码
      uses: actions/checkout@v4
      with:
        repository: 'oracle/docker-images'
        path: '${{ github.workspace }}/Oracle-Docker-images'

    - name: 检查Oracle-Docker-images目录
      run: |
        ls -l ${{ github.workspace }}/Oracle-Docker-images

    - name: 编译OracleJava镜像
      run: |
        chmod +x ${{ github.workspace }}/OracleJava.sh
        ${{ github.workspace }}/OracleJava.sh

    - name: 检查OracleJava镜像编译结果
      run: |
        ls -l ${{ github.workspace }}/Phone/
		ls -l ${{ github.workspace }}/Phone/Direct/

    - name: 编译ESurfingDockerPhone镜像
      run: |
        cd ${{ github.workspace }}/Phone
        chmod +x ./build.sh
        ./build.sh

    - name: 登录到 GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: 为 ESurfingDockerPhoneDocker 镜像打标签
      run: docker tag esurfingdockerphone ghcr.io/${{ github.repository_owner }}/esurfingdockerphonedocker:${{ env.TIMESTAMP }}

    - name: 推送 ESurfingDockerPhoneDocker 镜像到 GitHub Container Registry
      run: docker push ghcr.io/${{ github.repository_owner }}/esurfingdockerphonedocker:${{ env.TIMESTAMP }}

    - name: 为 ESurfingDockerPhoneDocker 镜像打latest标签
      run: docker tag esurfingdockerphone ghcr.io/${{ github.repository_owner }}/esurfingdockerphonedocker:latest

    - name: 推送 ESurfingDockerPhoneDocker:latest 镜像到 GitHub Container Registry
      run: docker push ghcr.io/${{ github.repository_owner }}/esurfingdockerphonedocker:latest

    - name: 下载 ESurfingDockerPhoneDocker:latest 镜像
      run: |
        docker save ghcr.io/${{ github.repository_owner }}/esurfingdockerphonedocker:latest -o ${{ github.workspace }}/Phone/ESurfingDockerPhone.tar.gz

    - name: 上传 ESurfingDockerPhoneDocker:latest 镜像
      uses: actions/upload-artifact@v3
      with:
        name: ESurfingDialer的Docker镜像
        path: '${{ github.workspace }}/Phone/ESurfingDockerPhone.tar.gz'

    - name: 下载Java21
      run: |
        chmod +x ${{ github.workspace }}/Phone/Download_jdk21.sh
        cd ${{ github.workspace }}/Phone/
        ./Download_jdk21.sh

    - name: 检查Java21下载结果
      run: |
        ls -l ${{ github.workspace }}/Phone/Direct
		ls -l ${{ github.workspace }}/Phone/Direct/jdk-21_linux-x64/
		ls -l ${{ github.workspace }}/Phone/Direct/jdk-21_windows-x64/

    - name: 修改Phone下的Direct文件夹为ESurfingDialer
      run: |
        cd ${{ github.workspace }}/Phone/
        mv ./Direct ./ESurfingDialer

    - name: 检查修改后的文件夹
      run: |
        ls -l ${{ github.workspace }}/Phone/ESurfingDialer

    - name: 压缩ESurfingDialer文件夹为zip格式
      run: |
        cd ${{ github.workspace }}/Phone/
        zip -r ESurfingDialer.zip ESurfingDialer

    - name: 检查压缩文件
      run: |
        ls -l ${{ github.workspace }}/Phone/ESurfingDialer.zip

    - name: 上传ESurfingDialer的免Docke直接运行版本
      uses: actions/upload-artifact@v3
      with:
        name: ESurfingDialer的免Docke直接运行版本
        path: '${{ github.workspace }}/Phone/ESurfingDialer.zip'

    - name: 获取天翼校园网官方Linux版本下载地址并下载，不能获取则使用预下载文件
      run: |
        cd ${{ github.workspace }}/PC/
        pip3 install requests beautifulsoup4 lxml
        python3 ./Get_ESurfingDialerClient.py

    - name: 检查天翼校园网官方Linux版本下载结果
      run: |
        ls -l ${{ github.workspace }}/PC

    - name: 生成更新日志
      run: echo "# 好的更新已经到来" > ${{ github.workspace }}-CHANGELOG.txt

    - name: 创建Release
      uses: softprops/action-gh-release@v2
      with:
        body_path: ${{ github.workspace }}-CHANGELOG.txt
        tag_name: V${{ env.TIMESTAMP }}
        token: ${{ secrets.GITHUB_TOKEN }}
        files: |
          ${{ github.workspace }}/ESurfingDialer/build/libs/*
          ${{ github.workspace }}/Phone/ESurfingDockerPhone.tar.gz
          ${{ github.workspace }}/Phone/ESurfingDialer.zip
