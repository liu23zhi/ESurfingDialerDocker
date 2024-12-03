#!/bin/bash

# 输入等待时间
TIMEOUT_Print=1

# 设置超时时间（秒）
TIMEOUT=5

# 设置调试模式
DEBUG=true

# 文件完整情况
COMPLETENESS=true

# 获取脚本所在目录的绝对地址
SCRIPT_DIR=$(dirname "$0")

# 设置Java Home路径
JAVA_HOME=$SCRIPT_DIR/jdk_linux-x64/

# 设置Java路径
JAVA_PATH=$JAVA_HOME/bin/java

# 设置Jar文件路径
JAR_FILE=$SCRIPT_DIR/client.jar

# 设置配置文件路径
CONFIG_FILE=$SCRIPT_DIR/ESurfingDialerAccount.config

TIMEOUT_Print_Command="sleep $TIMEOUT_Print"

# 检查文件是否完整
if [ ! -f "$JAVA_PATH" ]; then
    COMPLETENESS=false
    echo "Java执行文件不存在。文件缺失。"
    echo "请重新下载。"
    eval $TIMEOUT_Print_Command
fi

if [ ! -f "$JAR_FILE" ]; then
    COMPLETENESS=false
    echo "Jar文件不存在。文件缺失。"
    echo "请重新下载。"
    eval $TIMEOUT_Print_Command
fi

if [ "$COMPLETENESS" = "false" ]; then
    echo "文件不完整，无法继续执行。"
    eval $TIMEOUT_Print_Command
    exit 1
fi

# 设置Java环境变量
export PATH=$JAVA_HOME/bin:$PATH

# 读取配置文件内容
if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value
    do
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
    if [ "$DEBUG" = "true" ]; then
        echo "配置文件不存在，使用空置作为参数值。"
        eval $TIMEOUT_Print_Command
    fi
fi

Check_Config() {
    if [ "$DEBUG" = "true" ]; then
        echo "配置文件存在，读取到的用户名为: $USERNAME"
        echo "配置文件存在，读取到的密码为: $PASSWORD"
        echo "是否使用配置文件: $USE_CONFIG"
        echo "是否不再提示: $NO_PROMPT"
        eval $TIMEOUT_Print_Command
    fi

    if [ -z "$USE_CONFIG" ]; then
        USE_CONFIG=false
        if [ "$DEBUG" = "true" ]; then
            echo '"USE_CONFIG"参数不合法，已重置为默认值"false"'
            eval $TIMEOUT_Print_Command
        fi
    else
        if [ "$USE_CONFIG" != "false" ] && [ "$USE_CONFIG" != "true" ]; then
            USE_CONFIG=false
            if [ "$DEBUG" = "true" ]; then
                echo '"USE_CONFIG"参数不合法，已重置为默认值"false"'
                eval $TIMEOUT_Print_Command
            fi
        fi
    fi

    if [ -z "$NO_PROMPT" ]; then
        NO_PROMPT=false
        if [ "$DEBUG" = "true" ]; then
            echo '"NO_PROMPT"参数不合法，已重置为默认值"false"'
            eval $TIMEOUT_Print_Command
        fi
    else
        if [ "$NO_PROMPT" != "false" ] && [ "$NO_PROMPT" != "true" ]; then
            NO_PROMPT=false
            if [ "$DEBUG" = "true" ]; then
                echo '"NO_PROMPT"参数不合法，已重置为默认值"false"'
                eval $TIMEOUT_Print_Command
            fi
        fi
    fi

    if [ "$USE_CONFIG" = "true" ] && [ -z "$USERNAME" ]; then
        USE_CONFIG=false
        if [ "$DEBUG" = "true" ]; then
            echo '"USERNAME"参数不存在，无法设置"USE_CONFIG"成"true"'
            eval $TIMEOUT_Print_Command
        fi
    fi

    if [ "$USE_CONFIG" = "true" ] && [ -z "$PASSWORD" ]; then
        USE_CONFIG=false
        if [ "$DEBUG" = "true" ]; then
            echo '"PASSWORD"参数不存在，无法设置"USE_CONFIG"成"true"'
            eval $TIMEOUT_Print_Command
        fi
    fi

    if [ "$USE_CONFIG" = "true" ] && [ "$NO_PROMPT" = "false" ]; then
        NO_PROMPT=true
        if [ "$DEBUG" = "true" ]; then
            echo '"USE_CONFIG"已设置成"true"，"NO_PROMPT"应该被设置成"true"'
            eval $TIMEOUT_Print_Command
        fi
    fi
}

Check_Config

input_loop() {
    if [ "$USE_CONFIG" = "true" ]; then
        if [ "$DEBUG" = "true" ]; then
            echo "使用配置文件中的账号密码。"
            echo '若要取消不再显示设置界面，请将配置文件中的 "NO_PROMPT" 改为 "false"。'
            echo '若要关闭默认使用配置文件的账号密码，请将配置文件中的 "USE_CONFIG" 改为 "false"。'
            echo "配置文件路径: $CONFIG_FILE"
            eval $TIMEOUT_Print_Command
        fi
        USERNAME=$USERNAME
        PASSWORD=$PASSWORD
        execute_java
    else
        if [ "$DEBUG" = "true" ]; then
            echo "开始输入账号密码..."
        fi

        # 初始化变量
        NEW_USERNAME=""
        NEW_PASSWORD=""

        if [ -n "$USERNAME" ]; then
            echo "你上次使用的账号为: $USERNAME"
            eval $TIMEOUT_Print_Command
        else
            ACCOUNT_INPUT
        fi

        read -t $TIMEOUT -n 1 -p "是否使用上次账号 (默认Y): " USE_LAST_USERNAME
        echo
        if [ -z "$USE_LAST_USERNAME" ] || [ "$USE_LAST_USERNAME" = "Y" ] || [ "$USE_LAST_USERNAME" = "y" ]; then
            if [ "$DEBUG" = "true" ]; then
                echo "用户选择使用之前的账号，跳转至密码输部分"
            fi
            NEW_USERNAME=$USERNAME
            PASSWORD_INPUT
        else
            if [ "$DEBUG" = "true" ]; then
                echo "用户选择不使用之前的账号，跳转至输入账号部分"
            fi
            ACCOUNT_INPUT
        fi
    fi
}

ACCOUNT_INPUT() {
    read -p "请输入账号: " NEW_USERNAME
    if [ -z "$NEW_USERNAME" ] && [ -n "$USERNAME" ]; then
        echo "输入内容为空，将使用上次使用的账号: $USERNAME"
        NEW_USERNAME=$USERNAME
        PASSWORD_INPUT
    elif [ -z "$NEW_USERNAME" ]; then
        echo "没有账号，脚本无法继续执行。"
        eval $TIMEOUT_Print_Command
        exit 1
    else
        USERNAME=$NEW_USERNAME
        PASSWORD_INPUT
    fi
}

PASSWORD_INPUT() {
    if [ -n "$PASSWORD" ]; then
        echo "你上次使用的密码为: $PASSWORD"
    else
        PASSWORD_INPUT2
    fi

    read -t $TIMEOUT -n 1 -p "是否使用上次密码 (默认Y): " USE_LAST_PASSWORD
    echo
    if [ -z "$USE_LAST_PASSWORD" ] || [ "$USE_LAST_PASSWORD" = "Y" ] || [ "$USE_LAST_PASSWORD" = "y" ]; then
        if [ "$DEBUG" = "true" ]; then
            echo "用户选择使用之前的密码"
        fi
        NEW_PASSWORD=$PASSWORD
        if [ -z "$NEW_PASSWORD" ]; then
            echo "没有密码，脚本无法继续执行。"
            eval $TIMEOUT_Print_Command
            exit 1
        fi
        Settings_Page
    else
        if [ "$DEBUG" = "true" ]; then
            echo "用户选择不使用之前的密码，跳转至输入密码部分。"
        fi
        PASSWORD_INPUT2
    fi
}

PASSWORD_INPUT2() {
        read -p "请输入密码: " NEW_PASSWORD
        if [ -z "$NEW_PASSWORD" ]; then
            echo "没有密码，脚本无法继续执行。"
            eval $TIMEOUT_Print_Command
            exit 1
        else
            PASSWORD=$NEW_PASSWORD
            Settings_Page
        fi
}

Settings_Page() {
    if [ "$NO_PROMPT" = "true" ]; then
        echo
        echo "已设置不再弹出设置页面，"
        echo '若要取消不再显示设置界面，请将配置文件中的 "NO_PROMPT" 改为 "false"。'
        echo "配置文件路径: $CONFIG_FILE"
        echo

        eval $TIMEOUT_Print_Command
        NO_PROMPT_Two
    else
        read -t $TIMEOUT -n 1 -p "是否默认使用配置文件中的账号密码? (Y/N，默认Y): " USE_CONFIG_INPUT
        echo
        if [ -z "$USE_CONFIG_INPUT" ] || [ "$USE_CONFIG_INPUT" = "Y" ] || [ "$USE_CONFIG_INPUT" = "y" ]; then
            USE_CONFIG=true
            echo "已设置默认使用配置文件中的账号密码。"
        else
            USE_CONFIG=false
            echo "已取消设置默认使用配置文件中的账号密码。"
        fi
        eval $TIMEOUT_Print_Command

        read -t $TIMEOUT -n 1 -p "是否不再弹出此设置界面? (Y/N，默认N): " NO_PROMPT_INPUT
        echo
        if [ -z "$NO_PROMPT_INPUT" ] || [ "$NO_PROMPT_INPUT" = "N" ] || [ "$NO_PROMPT_INPUT" = "n" ]; then
            NO_PROMPT=false
            echo "已取消设置不再弹出此设置界面。"
        else
            NO_PROMPT=true
            echo "已设置不再弹出此设置界面。"
        fi
        eval $TIMEOUT_Print_Command

        NO_PROMPT_Two
    fi
}

NO_PROMPT_Two() {
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        if [ "$DEBUG" = "true" ]; then
            echo "配置文件不存在，已创建。"
            eval $TIMEOUT_Print_Command
        fi
    else
        > "$CONFIG_FILE" # 清空重建
        if [ "$DEBUG" = "true" ]; then
            echo "配置文件存在，已清空重建。"
            eval $TIMEOUT_Print_Command
        fi
    fi
    echo "USERNAME=$USERNAME" > "$CONFIG_FILE"
    echo "PASSWORD=$PASSWORD" >> "$CONFIG_FILE"
    echo "USE_CONFIG=$USE_CONFIG" >> "$CONFIG_FILE"
    echo "NO_PROMPT=$NO_PROMPT" >> "$CONFIG_FILE"
    if [ "$DEBUG" = "true" ]; then
        echo "账号密码和设置已保存到配置文件。"
    fi
    execute_java
}

execute_java() {
    if [ "$DEBUG" = "true" ]; then
        echo "执行Java程序，参数为: $JAVA_PATH -jar $JAR_FILE -u $USERNAME -p $PASSWORD"
    fi
    $JAVA_PATH -jar $JAR_FILE -u "$USERNAME" -p "$PASSWORD"
    if [ "$DEBUG" = "true" ]; then
        echo "Java程序执行完毕。"
    fi
}

input_loop

