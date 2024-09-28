import os
import time
import subprocess
import netifaces
import signal
import argparse

# 配置变量
SIMULATE_MODE = False  # 设置为True以启用模拟模式
CHECK_INTERVAL = 3  # 设置检测IP地址变化的间隔时间（秒）
PING_INTERVAL = 30  # 设置定时ping的间隔时间（秒）
PING_HOST = "connect.rom.miui.com"
PING_COUNT = 3  # 设置每次ping的次数
PING_TIMEOUT = 5  # 设置ping的超时时间（秒）
RESTART_DELAY = 5  # 设置重启后等待网络认证的时间（秒）
PING_INTERVAL_SEC = 2  # 设置每次ping之间的间隔时间（秒）

def get_ip_addresses():
    ip_addresses = {}
    for interface in netifaces.interfaces():
        addrs = netifaces.ifaddresses(interface)
        if netifaces.AF_INET in addrs:
            ip_info = addrs[netifaces.AF_INET][0]
            ip_addresses[interface] = ip_info['addr']
    return ip_addresses

def ping_host(host, count=1, timeout=5):
    command = f"ping -c {count} -W {timeout} {host}"
    response = os.system(command)
    return response == 0

def simulate_execution():
    print("模拟执行 ./ESurfingSvr")

def terminate_process(process):
    if process:
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
        print(f"已终止 ./ESurfingSvr，PID: {process.pid}")

def main(simulate=False, check_interval=10, ping_interval=30, ping_count=3, ping_timeout=5, restart_delay=30, ping_interval_sec=2, esurfing_args=None):
    current_ips = get_ip_addresses()
    print(f"初始IP地址: {current_ips}")
    
    if simulate:
        simulate_execution()
        process = None
    else:
        # 使用绝对路径执行
        esurfing_path = os.path.abspath("./ESurfingSvr")
        process = subprocess.Popen([esurfing_path] + esurfing_args)
        print(f"已启动 {esurfing_path}，PID: {process.pid}")
    
    def signal_handler(sig, frame):
        print("捕获到信号，正在终止程序...")
        terminate_process(process)
        exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    last_ping_time = time.time()
    
    try:
        while True:
            time.sleep(1)  # 每秒循环一次
            
            # 检查IP地址变化
            new_ips = get_ip_addresses()
            if new_ips != current_ips:
                print(f"IP地址发生变化: 从 {current_ips} 到 {new_ips}")
                current_ips = new_ips
                last_ping_time = time.time()  # 重置ping时间
                ping_success = False
                for attempt in range(ping_count):
                    if ping_host(PING_HOST, count=1, timeout=ping_timeout):
                        ping_success = True
                        break
                    if attempt < ping_count - 1:
                        time.sleep(ping_interval_sec)
                if not ping_success:
                    print("无法ping通 connect.rom.miui.com")
                    if simulate:
                        print("模拟终止并重新启动 ./ESurfingSvr")
                    else:
                        terminate_process(process)
                        time.sleep(restart_delay)  # 等待网络认证
                        esurfing_path = os.path.abspath("./ESurfingSvr")
                        process = subprocess.Popen([esurfing_path] + esurfing_args)
                        print(f"已重新启动 {esurfing_path}，PID: {process.pid}")
                else:
                    print(f"IP地址变化后，ping {PING_HOST} 成功")
            
            # 定时ping
            if time.time() - last_ping_time >= ping_interval:
                print(f"开始定时ping {PING_HOST}")
                ping_success = False
                for attempt in range(ping_count):
                    if ping_host(PING_HOST, count=1, timeout=ping_timeout):
                        ping_success = True
                        break
                    if attempt < ping_count - 1:
                        time.sleep(ping_interval_sec)
                if not ping_success:
                    print("定时ping失败，无法ping通 connect.rom.miui.com")
                    if simulate:
                        print("模拟终止并重新启动 ./ESurfingSvr")
                    else:
                        terminate_process(process)
                        time.sleep(restart_delay)  # 等待网络认证
                        esurfing_path = os.path.abspath("./ESurfingSvr")
                        process = subprocess.Popen([esurfing_path] + esurfing_args)
                        print(f"已重新启动 {esurfing_path}，PID: {process.pid}")
                else:
                    print(f"定时ping成功，{PING_HOST} 可达")
                last_ping_time = time.time()
    except KeyboardInterrupt:
        terminate_process(process)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="监控IP地址变化并管理 ./ESurfingSvr 进程")
    parser.add_argument('esurfing_args', nargs=argparse.REMAINDER, help="传递给 ./ESurfingSvr 的参数")
    args = parser.parse_args()
    
    main(simulate=SIMULATE_MODE, check_interval=CHECK_INTERVAL, ping_interval=PING_INTERVAL, ping_count=PING_COUNT, ping_timeout=PING_TIMEOUT, restart_delay=RESTART_DELAY, ping_interval_sec=PING_INTERVAL_SEC, esurfing_args=args.esurfing_args)
