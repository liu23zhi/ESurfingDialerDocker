#!/bin/bash

# 读取当前版本号
VERSION=$(cat ./version)

echo "当前版本号为：$VERSION"

# 解析版本号
IFS='.' read -r -a VERSION_PARTS <<< "$VERSION"

# 增加补丁版本号
PATCH_VERSION=$((VERSION_PARTS[2] + 1))

# 组装新的版本号
NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$PATCH_VERSION"

# 更新 ./version 文件中的版本号
echo "$NEW_VERSION" > ./version

# 输出新的版本号
echo "修改版本号为： $NEW_VERSION"
