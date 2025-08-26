#!/bin/bash
# 设置下载链接
URL_LINUX="https://download.oracle.com/java/24/latest/jdk-24_linux-aarch64_bin.tar.gz"
URL_WINDOWS="https://download.bell-sw.com/java/23.0.1+13/bellsoft-jdk23.0.1+13-windows-aarch64.zip"
# 设置本地文件名
FILE_NAME_LINUX="jdk-23_linux-aarch64_bin.tar.gz"
FILE_NAME_WINDOWS="jdk-23_windows-aarch64_bin.zip"
# 设置目标文件夹
TARGET_FOLDER_LINUX="./Direct/jdk-linux"
TARGET_FOLDER_WINDOWS="./Direct/jdk-windows"
# 设置下载文件夹
DOWNLOAD_FOLDER="./Direct"

#!/bin/bash

check_and_move_files() {        #                                       解压后的文件夹                    移动到文件夹 
    local extract_path=$1       # 使用示例   check_and_move_files "/home/zelly/ubuntu/tmp/123" "/home/zelly/ubuntu/tmp/def"
    local target_dir=$2

    echo "检查 $extract_path 是否存在孤立的文件夹"
    
    current_path="$extract_path"
    
    while true; do
        dirs=($(find "$current_path" -mindepth 1 -maxdepth 1 -type d))
        files=($(find "$current_path" -mindepth 1 -maxdepth 1 -type f))
        
        echo "正在检查路径: $current_path"
        echo "找到的文件夹: ${dirs[*]}"
        echo "找到的文件: ${files[*]}"
        
        if [[ ${#dirs[@]} -eq 1 && ${#files[@]} -eq 0 ]]; then
            current_path="${dirs[0]}"
            echo "进入下一层文件夹: $current_path"
        else
            break
        fi
    done

    if [[ ${#dirs[@]} -eq 0 && ${#files[@]} -eq 0 ]]; then
        echo "没有找到目标文件夹或文件。"
        exit 1
    fi

    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        echo "创建目标文件夹: $target_dir"
    fi
    
    for item in "$current_path"/*; do
        echo "移动文件或文件夹：$item -> $target_dir"
        mv "$item" "$target_dir"
    done
    
    echo "所有文件已成功移动到 $target_dir"

    # 检查并删除原文件夹
    remaining_dirs=($(find "$current_path" -mindepth 1 -maxdepth 1 -type d))
    remaining_files=($(find "$current_path" -mindepth 1 -maxdepth 1 -type f))
    
    if [[ ${#remaining_dirs[@]} -gt 0 || ${#remaining_files[@]} -gt 0 ]]; then
        echo "原文件夹在 $current_path 移动后不为空，无法删除。"
    else
        rm -rf "$current_path"
        echo "已删除原子文件夹：$current_path"
    fi
}

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
        # 检查是否为孤立的文件夹
        check_and_move_files $TARGET_FOLDER_LINUX $TARGET_FOLDER_LINUX
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
        # 检查是否为孤立的文件夹
        check_and_move_files $TARGET_FOLDER_WINDOWS $TARGET_FOLDER_WINDOWS
    else
        echo "Windows版本的JDK解压失败。"
        exit 1
    fi
fi
