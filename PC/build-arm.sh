#!/bin/sh
#cd./Phone
#docker build -t esurfingdockerpc .
#!/bin/bash
# 定义目标目录
TARGET_DIR="./ubuntu-base-24.04.1-base-amd64/app/"

# 如果目标目录不存在，则创建所需的文件夹
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo "目标目录 $TARGET_DIR 已创建。"
else
    echo "目标目录 $TARGET_DIR 已存在。"
fi

# 复制文件和文件夹到目标目录
cp -a ./run.sh "$TARGET_DIR"
cp -a ./run.py "$TARGET_DIR"
cp -a ./ESurfingDialerClient/. "$TARGET_DIR/ESurfingDialerClient/"
echo "所有文件和文件夹已成功复制到 $TARGET_DIR"
# To do:完善模拟环境

docker buildx build --platform linux/arm64 --tag esurfingdockerpc --load .
#docker save esurfingdockerphone -o./ESurfingDockerPhone.tar.gz
