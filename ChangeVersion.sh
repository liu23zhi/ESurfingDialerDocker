#!/bin/sh

# 更新 package.json 中的版本号，但不生成 git 标签
#npm version major -no-git-tag-version
#npm version minor -no-git-tag-version
npm version patch -no-git-tag-version
