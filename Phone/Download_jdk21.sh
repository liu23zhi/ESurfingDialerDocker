#!/bin/bash

# 设置下载链接
URL="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"

# 设置本地文件名
FILE_NAME="jdk-21_linux-x64_bin.tar.gz"

# 设置解压后的文件夹名称
FOLDER_NAME="jdk-21_linux-x64"

# 检查文件是否已存在
if [ -f "$FILE_NAME" ]; then
    echo "文件 $FILE_NAME 已存在，跳过下载。"
else
    # 下载文件
    echo "开始下载文件..."
    wget -c $URL -O $FILE_NAME
    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。"
        exit 1
    fi
fi

# 创建目标文件夹
if [ -d "$FOLDER_NAME" ]; then
    echo "文件夹 $FOLDER_NAME 已存在，跳过解压。"
else
    # 解压文件
    echo "开始解压文件..."
    tar -zxvf $FILE_NAME
    if [ $? -eq 0 ]; then
        echo "解压完成。"
    else
        echo "解压失败。"
        exit 1
    fi
fi
