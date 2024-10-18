#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerpc .
#!/bin/bash
# 定义目标目录
TARGET_DIR="./ubuntu-base/app"

#下载Ubuntu模拟环境
python3 ./Get_Ubuntu-base.py

# 如果目标目录不存在，则创建所需的文件夹
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo "目标目录 $TARGET_DIR 已创建。"
else
    echo "目标目录 $TARGET_DIR 已存在。"
fi

#复制文件或者文件夹到目标目录
copy_the_file_or_dirs(){        #                                       需要复制的文件                   目标目录 
    local original_file_or_dir=$1       # 使用示例   copy_the_file_or_dirs /home/zelly/ubuntu/tmp/123 /home/zelly/ubuntu/tmp/def
    original_file_or_dir=$(echo "$original_file_or_dir" | tr -d '"')    #删除多余的引号
    local target_dir=$2
    target_dir=$(echo "$target_dir" | tr -d '"')                        #删除多余的引号
    local last_dir=$(basename "$original_file_or_dir")
    if [ ! -d "$original_file_or_dir" | ! -f "$original_file_or_dir" ]
        echo "原文件或者文件夹不存在"
        exit 1
    fi
    if [ -d "$original_file_or_dir" ]
        echo "目标 $original_file_or_dir 是个文件夹"
        if [ ! -d "$target_dir/$last_dir"]
            echo "目标文件夹 $target_dir/$last_dir 不存在"
            echo "正在创建目标文件夹"
            mkdir -p "$target_dir/$last_dir"
            if [ ! -d "$target_dir/$last_dir" ]
                echo "目标文件夹 $target_dir/$last_dir 创建失败，请检查权限" 
                exit 1
            else
                echo "目标文件夹 $target_dir 创建成功"
            fi
            echo "正在复制 $original_file_or_dir 到 $target_dir"
            cp -a "$original_file_or_dir" "$target_dir/"
            echo "查看复制结果"
            ls -l $target_dir
            ls -l $target_dir/$last_dir
        fi
    fi
    if [ -f "$original_file_or_dir" ]
        echo "目标 $original_file_or_dir 是个文件"
        if [ -f $target_dir ]
            echo "目标路径 $target_dir 是文件,直接覆盖"
            echo "正在复制 $original_file_or_dir 到 $target_dir"
            cp -a "$original_file_or_dir" "$target_dir"
            echo "查看复制结果"
            ls -l $target_dir
            if [ ! -f "$target_dir" ]
                echo "目标文件 $original_file_or_dir 复制失败"
                exit 1
            else
                echo "目标文件 $original_file_or_dir 复制成功"
            fi
        fi
        if [ -d $target_dir ]
            echo "目标路径 $target_dir 是个文件夹"
            echo "正在复制 $original_file_or_dir 到 $target_dir/"
            cp -a "$original_file_or_dir" "$target_dir/"
            echo "查看复制结果"
            ls -l $target_dir
        fi
    fi
}

# 复制文件和文件夹到目标目录
# 使用示例   copy_the_file_or_dirs /home/zelly/ubuntu/tmp/123 /home/zelly/ubuntu/tmp/def             需要复制的文件                   目标目录
copy_the_file_or_dirs ./run.sh $TARGET_DIR
chmod -R 777 $TARGET_DIR/run.sh
copy_the_file_or_dirs ./run.py $TARGET_DIR
chmod -R 777 $TARGET_DIR/run.py
copy_the_file_or_dirs ./ESurfingDialerClient $TARGET_DIR
chmod -R 777 $TARGET_DIR/ESurfingDialerClient
copy_the_file_or_dirs ./chroot-install.sh $TARGET_DIR
chmod -R 777 $TARGET_DIR/chroot-install.sh

#完整环境代码位于               chroot-install.sh 
#初始化运行环境代码位于         configuration-chroot.sh


docker buildx build --platform linux/arm64 --tag esurfingdockerpc --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
