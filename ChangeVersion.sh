#!/bin/sh

# 更新 package.json 中的版本号，但不生成 git 标签
#npm version major -no-git-tag-version
#npm version minor -no-git-tag-version
npm version patch -no-git-tag-version

# 将版本号输出到环境变量
VERSION=$(npm view . version)
echo "VERSION=$VERSION" >> $GITHUB_ENV
