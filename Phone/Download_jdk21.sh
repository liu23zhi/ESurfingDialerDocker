#!/bin/bash
# 设置下载链接
URL_LINUX="https://download.oracle.com/java/21/archive/jdk-21.0.4_linux-x64_bin.tar.gz"
URL_WINDOWS="https://download.oracle.com/java/21/archive/jdk-21.0.4_windows-x64_bin.zip"
# 设置本地文件名
FILE_NAME_LINUX="jdk-21_linux-x64_bin.tar.gz"
FILE_NAME_WINDOWS="jdk-21_windows-x64_bin.zip"
# 设置目标文件夹
TARGET_FOLDER_LINUX="./Direct/jdk-21_linux-x64"
TARGET_FOLDER_WINDOWS="./Direct/jdk-21_windows-x64"
# 设置下载文件夹
DOWNLOAD_FOLDER="./Direct"
# 创建下载文件夹
if [ ! -d "$DOWNLOAD_FOLDER" ]; then
    echo "创建下载文件夹：$DOWNLOAD_FOLDER"
    mkdir -p "$DOWNLOAD_FOLDER"
fi
# 下载并解压Linux版本的JDK
if [ -f "$DOWNLOAD_FOLDER/$FILE_NAME_LINUX" ]; then
    echo "文件 $DOWNLOAD_FOLDER/$FILE_NAME_LINUX 已存在，跳过下载。"
else
    echo "开始下载Linux版本的JDK..."
    wget -c $URL_LINUX -O "$DOWNLOAD_FOLDER/$FILE_NAME_LINUX"
    if [ $? -eq 0 ]; then
        echo "Linux版本的JDK下载完成。"
    else
        echo "Linux版本的JDK下载失败。"
        exit 1
    fi
fi
# 检查Linux版本的JDK是否已解压
if [ -d "$TARGET_FOLDER_LINUX/bin" ]; then
    IS_EXTRACTED_LINUX=true
else
    IS_EXTRACTED_LINUX=false
fi
if [ "$IS_EXTRACTED_LINUX" = false ]; then
    if [ ! -d "$TARGET_FOLDER_LINUX" ]; then
        echo "创建Linux目标文件夹：$TARGET_FOLDER_LINUX"
        mkdir -p "$TARGET_FOLDER_LINUX"
    fi
    echo "开始解压Linux版本的JDK..."
    tar -zxvf "$DOWNLOAD_FOLDER/$FILE_NAME_LINUX" -C "$TARGET_FOLDER_LINUX"
    if [ $? -eq 0 ]; then
        echo "Linux版本的JDK解压完成。"
        # 删除原文件
        rm "$DOWNLOAD_FOLDER/$FILE_NAME_LINUX"
    else
        echo "Linux版本的JDK解压失败。"
        exit 1
    fi
fi
# 下载并解压Windows版本的JDK
if [ -f "$DOWNLOAD_FOLDER/$FILE_NAME_WINDOWS" ]; then
    echo "文件 $DOWNLOAD_FOLDER/$FILE_NAME_WINDOWS 已存在，跳过下载。"
else
    echo "开始下载Windows版本的JDK..."
    wget -c $URL_WINDOWS -O "$DOWNLOAD_FOLDER/$FILE_NAME_WINDOWS"
    if [ $? -eq 0 ]; then
        echo "Windows版本的JDK下载完成。"
    else
        echo "Windows版本的JDK下载失败。"
        exit 1
    fi
fi
# 检查Windows版本的JDK是否已解压
if [ -d "$TARGET_FOLDER_WINDOWS/bin" ]; then
    IS_EXTRACTED_WINDOWS=true
else
    IS_EXTRACTED_WINDOWS=false
fi
if [ "$IS_EXTRACTED_WINDOWS" = false ]; then
    if [ ! -d "$TARGET_FOLDER_WINDOWS" ]; then
        echo "创建Windows目标文件夹：$TARGET_FOLDER_WINDOWS"
        mkdir -p "$TARGET_FOLDER_WINDOWS"
    fi
    echo "开始解压Windows版本的JDK..."
    unzip "$DOWNLOAD_FOLDER/$FILE_NAME_WINDOWS" -d "$TARGET_FOLDER_WINDOWS"
    if [ $? -eq 0 ]; then
        echo "Windows版本的JDK解压完成。"
        # 删除原文件
        rm "$DOWNLOAD_FOLDER/$FILE_NAME_WINDOWS"
    else
        echo "Windows版本的JDK解压失败。"
        exit 1
    fi
fi
