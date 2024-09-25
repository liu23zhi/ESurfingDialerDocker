#!/bin/bash

# 设置超时时间（秒）
TIMEOUT=5

# 设置调试模式
DEBUG=false

# 文件完整情况
COMPLETENESS=true

# 获取脚本所在目录的绝对地址
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

# 设置Java Home路径
JAVA_HOME="$SCRIPT_DIR/jdk-21_linux-x64/jdk-21.0.4"

# 设置Java路径
JAVA_PATH="$JAVA_HOME/bin/java"

# 设置Jar文件路径
JAR_FILE="$SCRIPT_DIR/client.jar"

# 设置配置文件路径
CONFIG_FILE="$SCRIPT_DIR/ESurfingDialerAccount.config"

# 检查文件是否完整
if [ ! -f "$JAVA_PATH" ]; then
    COMPLETENESS=false
    echo "Java执行文件不存在。文件缺失。"
    echo "请重新下载。"
    sleep $TIMEOUT
fi

if [ ! -f "$JAR_FILE" ]; then
    COMPLETENESS=false
    echo "Jar文件不存在。文件缺失。"
    echo "请重新下载。"
    sleep $TIMEOUT
fi

if [ "$COMPLETENESS" = false ]; then
    echo "文件不完整，无法继续执行。"
    sleep $TIMEOUT
    exit 1
fi

# 设置Java环境变量
export PATH="$JAVA_HOME/bin:$PATH"

# 读取配置文件内容
if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value; do
        case "$key" in
            USERNAME) USERNAME="$value" ;;
            PASSWORD) PASSWORD="$value" ;;
            USE_CONFIG) USE_CONFIG="$value" ;;
            NO_PROMPT) NO_PROMPT="$value" ;;
        esac
    done < "$CONFIG_FILE"
else
    USERNAME=""
    PASSWORD=""
    USE_CONFIG=""
    NO_PROMPT=""
    if [ "$DEBUG" = true ]; then
        echo "配置文件不存在，使用空置作为参数值。"
        sleep $TIMEOUT
    fi
fi

# 检查配置文件参数
if [ "$DEBUG" = true ]; then
    echo "配置文件存在，读取到的用户名为: $USERNAME"
    echo "配置文件存在，读取到的密码为: $PASSWORD"
    echo "是否使用配置文件: $USE_CONFIG"
    echo "是否不再提示: $NO_PROMPT"
    sleep $TIMEOUT
fi

if [ -z "$USE_CONFIG" ]; then
    USE_CONFIG=false
    if [ "$DEBUG" = true ]; then
        echo "USE_CONFIG参数不合法，已重置为默认值false"
        sleep $TIMEOUT
    fi
fi

if [ "$USE_CONFIG" != "false" ] && [ "$USE_CONFIG" != "true" ]; then
    USE_CONFIG=false
    if [ "$DEBUG" = true ]; then
        echo "USE_CONFIG参数不合法，已重置为默认值false"
        sleep $TIMEOUT
    fi
fi

if [ -z "$NO_PROMPT" ]; then
    NO_PROMPT=false
    if [ "$DEBUG" = true ]; then
        echo "NO_PROMPT参数不合法，已重置为默认值false"
        sleep $TIMEOUT
    fi
fi

if [ "$NO_PROMPT" != "false" ] && [ "$NO_PROMPT" != "true" ]; then
    USE_CONFIG=false
    if [ "$DEBUG" = true ]; then
        echo "NO_PROMPT参数不合法，已重置为默认值false"
        sleep $TIMEOUT
    fi
fi

# 使用配置文件
if [ "$USE_CONFIG" = true ]; then
    if [ -z "$USERNAME" ]; then
        USE_CONFIG_CHECK=false
        if [ "$DEBUG" = true ]; then
            echo "USERNAME参数不存在，无法设置USE_CONFIG成true"
            sleep $TIMEOUT
        fi
    fi
fi

if [ "$USE_CONFIG" = true ]; then
    if [ -z "$PASSWORD" ]; then
        USE_CONFIG_CHECK=false
        if [ "$DEBUG" = true ]; then
            echo "PASSWORD参数不存在，无法设置USE_CONFIG成true"
            sleep $TIMEOUT
        fi
    fi
fi

if [ "$USE_CONFIG_CHECK" = false ]; then
    USE_CONFIG=false
    if [ "$DEBUG" = true ]; then
        echo "配置文件检查不通过，无法设置USE_CONFIG成true"
        sleep $TIMEOUT
    fi
fi

if [ "$USE_CONFIG" = true ]; then
    if [ "$NO_PROMPT" = false ]; then
        NO_PROMPT=true
        if [ "$DEBUG" = true ]; then
            echo "USE_CONFIG已设置成true，NO_PROMPT应该被设置成true"
            sleep $TIMEOUT
        fi
    fi
fi

# 输入账号密码
if [ "$USE_CONFIG" = true ]; then
    if [ "$DEBUG" = true ]; then
        echo "使用配置文件中的账号密码。"
        echo "若要取消不再显示设置界面，请将配置文件中的 NO_PROMPT 改为 false。"
        echo "若要关闭默认使用配置文件的账号密码，请将配置文件中的 USE_CONFIG 改为 false。"
        echo "配置文件路径: $CONFIG_FILE"
        sleep $TIMEOUT
    fi
else
    if [ "$DEBUG" = true ]; then
        echo "开始输入账号密码..."
    fi

    # 初始化变量
    NEW_USERNAME=""
    NEW_PASSWORD=""

    if [ ! -z "$USERNAME" ] && [ "$USERNAME" != "" ]; then
        echo "你上次使用的账号为: $USERNAME"
        sleep $TIMEOUT
    else
        :
    fi

    read -p "是否使用上次账号 (Y/N，默认Y) " choice
    case "$choice" in
        [Yy]*)
            :
            ;;
        *)
            if [ "$DEBUG" = true ]; then
                echo "用户选择不使用之前的账号，跳转至输入账号部分"
            fi
            read -p "请输入账号: " NEW_USERNAME
            if [ "$DEBUG" = true ]; then
                echo "你输入了：$NEW_USERNAME"
            fi

            if [ -z "$NEW_USERNAME" ]; then
                if [ ! -z "$USERNAME" ]; then
                    echo "输入内容为空，将使用上次使用的账号: $USERNAME"
                else
                    echo "没有账号，脚本无法继续执行。"
                    sleep $TIMEOUT
                    exit 1
                fi
            else
                USERNAME="$NEW_USERNAME"
            fi
            ;;
    esac

    if [ "$DEBUG" = true ]; then
        echo "用户名输入部分结束"
        echo "最终用户名为：$USERNAME"
    fi

    if [ ! -z "$PASSWORD" ] && [ "$PASSWORD" != "" ]; then
        echo "你上次使用的密码为: $PASSWORD"
        sleep $TIMEOUT
    else
        :
    fi

    read -p "是否使用上次密码 (Y/N，默认Y) " choice
    case "$choice" in
        [Yy]*)
            :
            ;;
        *)
            if [ "$DEBUG" = true ]; then
                echo "用户选择不使用之前的密码，跳转至输入密码部分"
            fi
            read -p "请输入密码: " NEW_PASSWORD
            if [ "$DEBUG" = true ]; then
                echo "你输入了：$NEW_PASSWORD"
            fi

            if [ -z "$NEW_PASSWORD" ]; then
                if [ ! -z "$PASSWORD" ]; then
                    if [ "$DEBUG" = true ]; then
                        echo "你上次使用的密码为: $PASSWORD"
                    fi
                else
                    echo "没有密码，脚本无法继续执行。"
                    sleep $TIMEOUT
                    exit 1
                fi
            else
                PASSWORD="$NEW_PASSWORD"
            fi
            ;;
    esac

    if [ "$DEBUG" = true ]; then
        echo "密码输入部分结束"
        echo "最终密码为：$PASSWORD"
    fi

    # 将获取到的账号密码和设置储存到config中
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        if [ "$DEBUG" = true ]; then
            echo "配置文件不存在，已创建。"
            sleep $TIMEOUT
        fi
    else
        rm "$CONFIG_FILE"
        touch "$CONFIG_FILE"
        if [ "$DEBUG" = true ]; then
            echo "配置文件存在，已清空重建。"
            sleep $TIMEOUT
        fi
    fi

    echo "USERNAME=$USERNAME" > "$CONFIG_FILE"
    echo "PASSWORD=$PASSWORD" >> "$CONFIG_FILE"
    echo "USE_CONFIG=$USE_CONFIG" >> "$CONFIG_FILE"
    echo "NO_PROMPT=$NO_PROMPT" >> "$CONFIG_FILE"
    if [ "$DEBUG" = true ]; then
        echo "账号密码和设置已保存到配置文件。"
    fi
fi

# 执行Java程序
if [ "$DEBUG" = true ]; then
    echo "执行Java程序，参数为: \"$JAVA_PATH\" -jar \"$JAR_FILE\" -u \"$USERNAME\" -p \"$PASSWORD\""
fi
"$JAVA_PATH" -jar "$JAR_FILE" -u "$USERNAME" -p "$PASSWORD"

if [ "$DEBUG" = true ]; then
    echo "Java程序执行完毕。"
fi