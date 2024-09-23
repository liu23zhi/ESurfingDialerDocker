#!/bin/bash

# 定义脚本目录变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

mkdir Phone

# 查找最新的JAR文件函数
find_latest_jar() {
    local search_pattern="$1"
    local directory="$2"
    echo "在目录 $directory 中搜索匹配 $search_pattern 的最新JAR文件..."
    local files=$(find "$directory" -type f -name "$search_pattern" -print)
    if [[ -z "$files" ]]; then
        echo "没有找到匹配的文件，脚本将退出。"
        exit 1
    fi
    local latest_jar=$(find "$directory" -type f -name "$search_pattern" | sort -t. -k 2,2n -k 3,3n -k 4,4n | tail -1)
    if [[ -n "$latest_jar" ]]; then
        echo "找到的最新JAR文件路径为：$latest_jar"
        cp "$latest_jar" "$SCRIPT_DIR/Phone/client.jar"
    else
        echo "没有找到包含关键词的JAR文件，脚本将退出。"
        exit 1
    fi
}

project_dir="$SCRIPT_DIR/ESurfingDialer"
jar_search_dir="$project_dir/build/libs"
jar_search_pattern="*ESurfing*.jar"
find_latest_jar "$jar_search_pattern" "$jar_search_dir"