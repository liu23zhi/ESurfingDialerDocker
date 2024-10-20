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

# 设置日志级别
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# 设置默认参数
DEFAULT_PING_HOSTS = ["www.baidu.com", "connect.rom.miui.com"]  # 默认的 ping 检测主机列表
DEFAULT_PING_COUNT = 1  # 每次 ping 操作尝试的次数
DEFAULT_PING_TIMEOUT = 2  # 每次 ping 操作的超时时间（秒）
DEFAULT_NETWORK_AUTH_TIMEOUT = 30  # 网络认证的超时时间（秒）
DEFAULT_MONITOR_PING_INTERVAL = 5  # 网络 ping 检测的间隔时间（秒）
DEFAULT_MONITOR_IP_INTERVAL = 3  # IP 地址检测的间隔时间（秒）
DEFAULT_MAX_RESTART_COUNT = 5  # 允许的最大重启次数
DEFAULT_MAX_NO_IP_COUNT = 3  # 允许的最大无 IP 地址次数
DEFAULT_WAIT_AFTER_PING = 5  # ping 失败后的等待时间（秒）
DEFAULT_RESTART_ON_NO_IP = True  # 是否在多次无法获取 IP 地址时重启
DEFAULT_RESTART_ON_NO_PING = True  # 是否在多次 ping 失败时重启
DEFAULT_WAIT_AFTER_NO_PING = 10  # 在 ping 失败后重启前的等待时间（秒）

# 获取脚本绝对路径
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 设置可执行文件路径
# ESURFING_DIAlER_CLIENT_PATH = os.path.join(SCRIPT_DIR, "ESurfingDialerClient")
ESURFING_DIAlER_CLIENT_PATH = os.path.join(SCRIPT_DIR)
ESURFING_SVR_PATH = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "ESurfingSvr")

# 设置日志文件路径
LOG_DIR = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "Log")

def get_current_date_str():
    """获取当前日期字符串，格式为 YYYYMMDD。"""
    return datetime.now().strftime("%Y%m%d")

def get_log_file_path():
    """获取最新的日志文件路径。"""
    files = os.listdir(LOG_DIR)
    log_files = [f for f in files if re.match(r"\d{8}_Info\.log$", f)]
    if log_files:
        log_files.sort()
        return os.path.join(LOG_DIR, log_files[-1])
    return None

def get_ip_addresses():
    """获取所有网卡的 IP 地址。"""
    ip_addresses = []
    for interface, addresses in psutil.net_if_addrs().items():
        for address in addresses:
            if address.family == socket.AF_INET:
                ip_addresses.append(address.address)
    return ip_addresses

def ping_host(host, count=1, timeout=DEFAULT_PING_TIMEOUT):
    """使用系统 ping 命令 ping 指定主机。"""
    try:
        # 使用 subprocess.run 执行系统 ping 命令
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

def multi_ping(hosts, count=DEFAULT_PING_COUNT, timeout=DEFAULT_PING_TIMEOUT, wait_after_ping=DEFAULT_WAIT_AFTER_PING):
    """多次 ping 指定主机列表。"""
    for host in hosts:
        logging.info(f"开始 ping {host}...")
        if ping_host(host, count, timeout):
            logging.info(f"ping {host} 成功！")
            return True
        else:
            logging.warning(f"ping {host} 失败，等待 {wait_after_ping} 秒后重试...")
            time.sleep(wait_after_ping)
    return False

def start_esurfing_svr(args):
    """启动 ESurfingSvr 进程。"""
    global esurfing_svr_pid
    command = [ESURFING_SVR_PATH] + args
    logging.info(f"启动 ESurfingSvr: {command}")
    esurfing_svr_process = subprocess.Popen(command)
    esurfing_svr_pid = esurfing_svr_process.pid
    logging.info(f"ESurfingSvr 进程 ID: {esurfing_svr_pid}")

def stop_esurfing_svr():
    """停止 ESurfingSvr 进程。"""
    global esurfing_svr_pid
    if esurfing_svr_pid:
        logging.info(f"尝试停止 ESurfingSvr 进程...")
        try:
            subprocess.run(["kill", str(esurfing_svr_pid)])
            logging.info(f"ESurfingSvr 进程已停止。")
            esurfing_svr_pid = None
        except Exception as e:
            logging.error(f"停止 ESurfingSvr 进程失败: {e}")

def signal_handler(sig, frame):
    """处理信号，确保程序可以正确退出。"""
    logging.info("收到终止信号，正在关闭程序...")
    stop_esurfing_svr()
    logging.info("程序已关闭。")
    exit(0)

def network_auth():
    """等待网络认证完成。"""
    logging.info(f"等待网络认证...")
    time.sleep(NETWORK_AUTH_TIMEOUT)
    current_ips = get_ip_addresses()
    if not current_ips:
        logging.error(f"网络认证失败，无法获取 IP 地址。")
        return False
    logging.info(f"网络认证成功，当前 IP 地址: {current_ips}")
    return True

def monitor_network():
    """监控网络连接状态。"""
    restart_count = 0
    no_ip_count = 0
    network_authenticated = False

    while True:
        if not network_authenticated:
            if not network_auth():
                logging.warning(f"网络认证失败，等待 {WAIT_AFTER_NO_PING} 秒后重试...")
                time.sleep(WAIT_AFTER_NO_PING)
                continue
            network_authenticated = True

        # 检查 IP 地址
        current_ips = get_ip_addresses()
        if not current_ips:
            no_ip_count += 1
            logging.warning(f"获取 IP 地址失败，已连续失败 {no_ip_count} 次。")
            if no_ip_count >= MAX_NO_IP_COUNT:
                logging.critical(f"获取 IP 地址连续失败 {MAX_NO_IP_COUNT} 次，退出程序。")
                exit(1)
            time.sleep(MONITOR_IP_INTERVAL)
            continue
        else:
            no_ip_count = 0
            logging.info(f"当前网卡 IP 地址: {current_ips}")

        # 进行 ping 检测
        if not multi_ping(PING_HOSTS):
            if RESTART_ON_NO_PING:
                restart_count += 1
                logging.warning(f"网络连接失败，已连续重启 {restart_count} 次。")
                if restart_count >= MAX_RESTART_COUNT:
                    logging.critical(f"网络连接失败，已连续重启 {MAX_RESTART_COUNT} 次，退出程序。")
                    exit(1)
                stop_esurfing_svr()
                time.sleep(WAIT_AFTER_NO_PING)
                start_esurfing_svr(ARGS)
                restart_count = 0
                network_authenticated = False  # 重置网络认证标志
            else:
                logging.warning(f"网络连接失败，但未启用自动重启。")
        else:
            restart_count = 0

        time.sleep(MONITOR_PING_INTERVAL)

if __name__ == "__main__":
    # 解析命令行参数
    parser = argparse.ArgumentParser()
    parser.add_argument("args", nargs="*", help="传递给 ESurfingSvr 的参数")
    args = parser.parse_args()
    ARGS = args.args

    # 设置变量
    PING_HOSTS = DEFAULT_PING_HOSTS
    PING_COUNT = DEFAULT_PING_COUNT
    PING_TIMEOUT = DEFAULT_PING_TIMEOUT
    NETWORK_AUTH_TIMEOUT = DEFAULT_NETWORK_AUTH_TIMEOUT
    MONITOR_PING_INTERVAL = DEFAULT_MONITOR_PING_INTERVAL
    MONITOR_IP_INTERVAL = DEFAULT_MONITOR_IP_INTERVAL
    MAX_RESTART_COUNT = DEFAULT_MAX_RESTART_COUNT
    MAX_NO_IP_COUNT = DEFAULT_MAX_NO_IP_COUNT
    WAIT_AFTER_PING = DEFAULT_WAIT_AFTER_PING
    RESTART_ON_NO_IP = DEFAULT_RESTART_ON_NO_IP
    RESTART_ON_NO_PING = DEFAULT_RESTART_ON_NO_PING
    WAIT_AFTER_NO_PING = DEFAULT_WAIT_AFTER_NO_PING

    esurfing_svr_pid = None

    # 注册信号处理函数
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # 启动 ESurfingSvr
    start_esurfing_svr(ARGS)

    # 开始监控网络连接状态
    monitor_network()