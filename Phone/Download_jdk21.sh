#!/bin/bash

# 设置下载链接
URL="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"

# 设置本地文件名
FILE_NAME="jdk-21_linux-x64_bin.tar.gz"

# 设置目标文件夹
TARGET_FOLDER="./Direct/jdk-21_linux-x64"

# 设置下载文件夹
DOWNLOAD_FOLDER="./Direct"

# 创建下载文件夹
if [ ! -d "$DOWNLOAD_FOLDER" ]; then
    echo "创建下载文件夹：$DOWNLOAD_FOLDER"
    mkdir -p "$DOWNLOAD_FOLDER"
fi

# 检查文件是否已存在
if [ -f "$DOWNLOAD_FOLDER/$FILE_NAME" ]; then
    echo "文件 $DOWNLOAD_FOLDER/$FILE_NAME 已存在，跳过下载。"
else
    # 下载文件
    echo "开始下载文件..."
    wget -c $URL -O "$DOWNLOAD_FOLDER/$FILE_NAME"
    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。"
        exit 1
    fi
fi

# 创建目标文件夹
if [ ! -d "$TARGET_FOLDER" ]; then
    echo "创建目标文件夹：$TARGET_FOLDER"
    mkdir -p "$TARGET_FOLDER"
fi

# 解压文件
if [ -d "$TARGET_FOLDER" ]; then
    echo "文件夹 $TARGET_FOLDER 已存在，跳过解压。"
else
    echo "开始解压文件..."
    tar -zxvf "$DOWNLOAD_FOLDER/$FILE_NAME" -C "$TARGET_FOLDER"
    if [ $? -eq 0 ]; then
        echo "解压完成。"
    else
        echo "解压失败。"
        exit 1
    fi
fi
