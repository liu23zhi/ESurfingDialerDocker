import subprocess
import time
import os
import re
import argparse
from datetime import datetime
import socket
import psutil
import logging
import signal
import select
import threading
# 设置日志级别
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
# 设置默认参数
DEFAULT_PING_HOSTS = ["www.baidu.com", "connect.rom.miui.com"]  # 默认的 ping 检测主机列表
DEFAULT_PING_COUNT = 1  # 每次 ping 操作尝试的次数
DEFAULT_PING_TIMEOUT = 2  # 每次 ping 操作的超时时间（秒）
DEFAULT_NETWORK_AUTH_TIMEOUT = 30  # 网络认证的超时时间（秒）
DEFAULT_MONITOR_PING_INTERVAL = 10  # 网络 ping 检测的间隔时间（秒）
DEFAULT_MONITOR_IP_INTERVAL = 3  # IP 地址检测的间隔时间（秒）
DEFAULT_WAIT_AFTER_IP_CHANGE = 1  # 获取IP地址变化后进行PING校验的等待时间（秒）
DEFAULT_MAX_NO_IP_COUNT = 3  # 允许的最大无 IP 地址次数
DEFAULT_WAIT_AFTER_NO_IP = 3  # 获取IP地址失败后的等待时间（秒）
DEFAULT_WAIT_AFTER_PING = 5  # ping 失败后的等待时间（秒）
ESURFINGSRV_CLOSE_WAITTIME = 5  # ESurfingSvr 关闭后等待多久之后重启（秒）
LESS_PING_TIME = 2  # 最少的PING次数
# 获取脚本绝对路径
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# 设置可执行文件路径
ESURFING_DIAlER_CLIENT_PATH = os.path.join(SCRIPT_DIR)
ESURFING_SVR_PATH = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "ESurfingSvr")
# 设置日志文件路径
LOG_DIR = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "Log")
# 定义一个新函数来解析错误代码
def explain_the_error_code(content):
    # 如果内容中包含特定的错误码，则解释该错误码
    if '140000' in content:
        logging.info("无错误。（错误码：140000）")
def get_current_date_str():
    """获取当前日期字符串，格式为 YYYYMMDD。"""
    return datetime.now().strftime("%Y%m%d")
def get_or_create_log_file():
    """获取或创建当天的日志文件路径。"""
    current_date_str = get_current_date_str()
    log_filename = f"{current_date_str}_Info.log"
    log_file_path = os.path.join(LOG_DIR, log_filename)
    # 如果文件不存在，则创建它
    if not os.path.exists(log_file_path):
        open(log_file_path, 'a').close()  # 创建空文件
    return log_file_path
# 定义ping主机的函数
def ping_host(host, count=1, timeout=DEFAULT_PING_TIMEOUT):
    """使用系统 ping 命令 ping 指定主机。"""
    try:
        # 使用 subprocess.run 执行系统 ping 命令
        if args.use_qemu:
            result = subprocess.run(
                ['/usr/bin/qemu-x86_64-static','/usr/bin/bash','-c','ping', '-c', str(count), '-W', str(timeout * 1000), host],
                stdout=subprocess.PIPE,  # 将标准输出重定向到管道
                stderr=subprocess.PIPE,  # 将标准错误重定向到管道
            )
        else:
            result = subprocess.run(
                ['ping', '-c', str(count), '-W', str(timeout * 1000), host],
                stdout=subprocess.PIPE,  # 将标准输出重定向到管道
                stderr=subprocess.PIPE,  # 将标准错误重定向到管道
            )
        if result.returncode == 0:
            logging.info(f"ping {host} 成功！\n输出:\n{result.stdout.decode()}")
            return True
        else:
            logging.error(f"ping {host} 失败！\n输出:\n{result.stdout.decode()}\n错误:\n{result.stderr.decode()}")
            return False
    except Exception as e:
        logging.error(f"ping {host} 失败: {e}")
        return False
# 定义多次ping主机列表的函数
def multi_ping(hosts=DEFAULT_PING_HOSTS, count=DEFAULT_PING_COUNT, timeout=DEFAULT_PING_TIMEOUT, wait_after_ping=DEFAULT_WAIT_AFTER_PING):
    """多次 ping 指定主机列表。"""
    Try_time = 0
    def ping_from_hosts():
        for index, host in enumerate(hosts):
            logging.info(f"开始 ping {host}...")
            if ping_host(host, count, timeout):
                logging.info(f"ping {host} 成功！")
                return True
            else:
                if index == len(hosts) - 1 and Try_time != 0:
                  logging.warning("以所有主机ping失败，没有更多主机可尝试。")
                else:
                  logging.warning(f"ping {host} 失败，稍后重试...")
                time.sleep(wait_after_ping)
        return False
    while Try_time < LESS_PING_TIME:
        if ping_from_hosts():
            return True
        else:
            Try_time += 1
            logging.info(f"尝试次数：{Try_time}")
    return False
# 启动 ESurfingSvr 的函数
def start_esurfingsvr(account, password):
    """启动 ESurfingSvr 进程，并监控其运行状态。"""
    logging.info("正在启动 ESurfingSvr...")
    # 构建命令行参数
    if args.use_qemu:
        command = ['/usr/bin/qemu-x86_64-static','/usr/bin/bash','-c',ESURFING_SVR_PATH, account, password]
    else:
    # 构建命令行参数
        command = [ESURFING_SVR_PATH, account, password]
    # 启动进程
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    # 监控进程输出
    def monitor_output(process):
        try:
            while True:
                # 使用 select 检查输出是否就绪
                ready, _, _ = select.select([process.stdout, process.stderr], [], [])
                for stream in ready:
                    line = stream.readline()
                    if line:
                        logging.info(f"ESurfingSvr 输出: {line.strip()}")
                        # 检查是否出现错误代码
                        explain_the_error_code(line)
                    else:
                        # 如果没有输出，可能进程已经结束
                        break
        except Exception as e:
            logging.error(f"监控 ESurfingSvr 输出时发生错误: {e}")
    # 启动监控线程
    threading.Thread(target=monitor_output, args=(process,), daemon=True).start()
    return process
# 主函数
def main():
    # 解析命令行参数
    parser = argparse.ArgumentParser(description="ESurfing 网络连接监控脚本")
    parser.add_argument("account", help="网络连接账号")
    parser.add_argument("password", help="网络连接密码")
    #被迫使用qemu来解析中国电信Linux客户端
    parser.add_argument("--use_qemu", action='store_true', help="是否使用QEMU (默认为False)")
    global args #全局化变量
    args = parser.parse_args()
    global network_authenticated  # 标记网络是否已经完成认证
    network_authenticated = False
    # 启动 ESurfingSvr
    esurfingsvr_process = start_esurfingsvr(args.account, args.password)
    # 开始进入监视循环
    try:
        while True:
            # 检查网络是否认证成功
            if not network_authenticated:
                # 如果网络未认证，等待一段时间
                logging.info("网络未认证，等待认证...")
                time.sleep(DEFAULT_NETWORK_AUTH_TIMEOUT)
                network_authenticated = True  # 假设网络认证成功
            # 进行网络监控
            if multi_ping():
                logging.info("网络连接正常。")
            else:
                logging.error("网络连接异常，尝试重启 ESurfingSvr...")
                # 杀死 ESurfingSvr 进程
                esurfingsvr_process.terminate()
                esurfingsvr_process.wait(timeout=ESURFINGSRV_CLOSE_WAITTIME)
                # 重新启动 ESurfingSvr
                esurfingsvr_process = start_esurfingsvr(args.account, args.password)
            # 等待一段时间再次检查
            time.sleep(DEFAULT_MONITOR_PING_INTERVAL)
    except KeyboardInterrupt:
        logging.info("脚本被用户中断。")
    except Exception as e:
        logging.error(f"脚本运行出错: {e}")
    finally:
        # 清理资源
        if esurfingsvr_process.poll() is None:
            esurfingsvr_process.terminate()
            esurfingsvr_process.wait()
if __name__ == "__main__":
    main()