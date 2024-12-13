#!/bin/bash

# 读取当前版本号
VERSION=$(cat ./version)

# 输出当前版本号
echo "当前版本号为：$VERSION"

# 将版本号按 . 分割成数组存储
IFS='.' read -r -a VERSION_PARTS <<< "$VERSION"

# 检查更新类型参数
UPDATE_TYPE=$1

# 定义合法的更新类型
VALID_TYPES=("major" "normal" "minor" "preview")

# 检查更新类型是否在合法的更新类型列表中
if [[ ! " ${VALID_TYPES[@]} " =~ " ${UPDATE_TYPE} " ]]; then
    echo "更新类型无效或未指定，默认为小版本更新"
    UPDATE_TYPE="minor"
else
    echo "更新类型为：$UPDATE_TYPE"
fi

# 输出解析后的版本号数组
echo "解析后的版本号为："
for i in "${!VERSION_PARTS[@]}"; do
    echo "版本部分 $i: ${VERSION_PARTS[$i]}"
done

# 根据更新类型修改版本号
case $UPDATE_TYPE in
    "major")
        # 大版本更新：主版本号加1，次版本号和补丁版本号置为0
        MAJOR_VERSION=$((VERSION_PARTS[0] + 1))
        NEW_VERSION="$MAJOR_VERSION.0.0"
        echo "执行大版本更新：将主版本号增加到 $MAJOR_VERSION，次版本号和补丁版本号重置为 0"
        ;;
    "normal")
        # 普通更新：次版本号加1
        MINOR_VERSION=$((VERSION_PARTS[1] + 1))
        NEW_VERSION="${VERSION_PARTS[0]}.$MINOR_VERSION.0"
        echo "执行普通更新：将次版本号增加到 $MINOR_VERSION，补丁版本号重置为 0"
        ;;
    "minor")
        # 小版本更新：补丁版本号加1
        if [[ "${VERSION_PARTS[2]}" == *"-preview-"* ]]; then
            # 如果当前版本是预览版本，移除预览标签并增加补丁版本号
            IFS='-' read -r -a PREVIEW_PARTS <<< "${VERSION_PARTS[2]}"
            PATCH_VERSION=$((PREVIEW_PARTS[0] + 1))
            echo "当前版本是预览版本，将其转换为正式版本并增加补丁版本号至 $PATCH_VERSION"
        else
            PATCH_VERSION=$((VERSION_PARTS[2] + 1))
            echo "执行小版本更新：将补丁版本号增加到 $PATCH_VERSION"
        fi
        NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$PATCH_VERSION"
        ;;
    "preview")
        # 预览版本更新：如果当前版本已经是预览版本，增加预览版本号；否则，初始预览版本号为-preview-1
        if [[ "${VERSION_PARTS[2]}" == *"-preview-"* ]]; then
            # 分割预览版本号，增加预览版本号
            IFS='-' read -r -a PREVIEW_PARTS <<< "${VERSION_PARTS[2]}"
            PREVIEW_NUMBER=$((PREVIEW_PARTS[2] + 1))
            NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${PREVIEW_PARTS[0]}-preview-$PREVIEW_NUMBER"
            echo "当前版本是预览版本，增加预览版本号至 $NEW_VERSION"
        else
            # 初始预览版本号为-preview-1
            NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}-preview-1"
            echo "当前版本不是预览版本，设置预览版本号为：$NEW_VERSION"
        fi
        ;;
    *)
        # 未知的更新类型，提示用户并退出
        echo "未知的更新类型：$UPDATE_TYPE"
        exit 1
        ;;
esac

# 更新 ./version 文件中的版本号
echo "$NEW_VERSION" > ./version

# 输出新的版本号
echo "修改版本号为：$NEW_VERSION"
