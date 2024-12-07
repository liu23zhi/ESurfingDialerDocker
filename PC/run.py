import subprocess
import time
import os
import re
import argparse
import datetime
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
ESURFINGSRV_CLOSE_WAITTIME = 5 # ESurfingSvr 关闭超时时间（秒）
ESURFINGSRV_RESTART_WAITTIME = 5 # ESurfingSvr 关闭后等待多久之后重启（秒）
LESS_PING_TIME= 2 #最少的PING次数

# 获取脚本绝对路径
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 设置可执行文件路径
# ESURFING_DIAlER_CLIENT_PATH = os.path.join(SCRIPT_DIR, "ESurfingDialerClient")
ESURFING_DIAlER_CLIENT_PATH = os.path.join(SCRIPT_DIR)
ESURFING_SVR_PATH = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "ESurfingSvr")

# 设置日志文件路径
LOG_DIR = os.path.join(ESURFING_DIAlER_CLIENT_PATH, "Log")

#定义一个新函数来解析错误代码
# def explain_the_error_code(content):
#   if '140000' in content:
#      logging.info(f"无错误。（错误码：140000）")

# from error_code import explain_the_error_code
#定义一个新函数来解析错误代码
def explain_the_error_code(content):
  # 如果内容中包含特定的错误码，则解释该错误码
  if '140000' in content:
    print(f"未知错误。（错误码：140000）")
  if '140001' in content:
    print(f"无效的请求。（错误码：140001）")
  if '140002' in content:
    print(f"不支持该系统。（错误码：140002）")
  if '140003' in content:
    print(f"服务器无法识别你的版本。（错误码：403）")
  if '140010' in content:
    print(f"无效的客户端IP地址。（错误码：140010）")
  if '140011' in content:
    print(f"无效的客户端MAC地址。（错误码：140011）")
  if '140012' in content:
    print(f"无效的客户端ID。（错误码：140012）")
  if '140013' in content:
    print(f"无效的算法ID。（错误码：140013）")
  if '140014' in content:
    print(f"无效的ticket。（错误码：140014）")
  if '140015' in content:
    print(f"校验值错误。（错误码：140015）")
  if '140100' in content:
    print(f"无效的用户名、密码。（错误码：140100）")
  if '140101' in content:
    print(f"无效的挑战值。（错误码：140101）")
  if '140102' in content:
    print(f"您的拨号请求已被服务器拒绝，详情请联系10000查询。（错误码：201）")
  if '140103' in content:
    print(f"网关可容纳的接入数已满。（错误码：140103）")
  if '140104' in content:
    print(f"对应的用户不存在。（错误码：140104）")
  if '140105' in content:
    print(f"用户账号受限。（错误码：140105）")
  if '140200' in content:
    print(f"密钥过期。（错误码：140200）")
  if '140300' in content:
    print(f"正在等待终端发起认证。（错误码：140300）")
  if '140301' in content:
    print(f"正在等待服务端进行验证。（错误码：140301）")
  if '140901' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：301）")
  if '140902' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：302）")
  if '140990' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：303）")
  if '140102.1' in content:
    print(f"认证请求被拒绝。（1）")
  if '140102.2' in content:
    print(f"您已在客户端登录了此账号，不能重复登录。（2）")
  if '140102.3' in content:
    print(f"认证服务器忙，请稍后再试。（3）")
  if '140102.4' in content:
    print(f"认证失败，请检查网络后重试。（4）")
  if '140102.11010000' in content:
    print(f"找不到SDX信息，请咨询校园网络端口是否已开通。(11010000)")
  if '140102.13001000' in content:
    print(f"认证请求被拒绝。(13001000)")
  if '140102.13003000' in content:
    print(f"认证服务器忙，请稍后再试。(13003000)")
  if '140102.13005000' in content:
    print(f"请求认证超时，请检查网络后重试。(13005000)")
  if '140102.13012000' in content:
    print(f"帐号或密码错误。(13012000)")
  if '140102.13016000' in content:
    print(f"输入的帐号不存在，注意帐号无需@后缀。(13016000)")
  if '140102.13017000' in content:
    print(f"帐号状态异常，请咨询校园营业厅。（13017000)")
  if '140102.13014000' in content:
    print(f"终端数超出限制，请先退出其他已登录终端。（13014000）")
  if '140102.13015000' in content:
    print(f"账户余额不足。(13015000)")
  if '140102.13018000' in content:
    print(f"拨号类型错误。(13018000)")
  if '140102.13019000' in content:
    print(f"终端类型错误。(13019000)")
  if '140102.13020000' in content:
    print(f"体验活动已结束。(13020000)")
  if '140102.13021000' in content:
    print(f"体验帐号已过期。(13021000)")
  if '140102.13022000' in content:
    print(f"今日体验时长已用完，请明天再试。(13022000)")
  if '140102.11064000' in content:
    print(f"帐号登录过于频繁，请5分钟后重新登录。(11064000)")
  if '150000' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：304）")
  if '150001' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：305）")
  if '150002' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：306）")
  if '150003' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：307）")
  if '150009' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：308）")
  if '150010' in content:
    print(f"(>﹏<)客户端服务器好像抽风了，程序猿正在努力抢修中！（错误码：9999）")
  if '150100' in content:
    print(f"网络请求失败")
  if '150101' in content:
    print(f"(>﹏<)网络好像不通了(%s)，获取配置项失败（错误码：102）")
  if '150102' in content:
    print(f"(>﹏<)网络好像不通了(%s)，本次拨号请求发送失败。（错误码：103）")
  if '150103' in content:
    print(f"(>﹏<)网络好像不通了(%s)，获取ticket失败。（错误码：104）")
  if '150104' in content:
    print(f"(>﹏<)网络好像不通了(%s)，网络状态检查失败。（错误码：105）")
  if '150105' in content:
    print(f"(>﹏<)网络好像不通了(%s)，本次下线请求发送失败。（错误码：106）")
  if '150106' in content:
    print(f"数据加密失败，请使用客户端检测工具或其他安全管理软件进行修复。（错误码：313）")
  if '150107' in content:
    print(f"（┬＿┬）网络好像不通！请检查网络配置或使用检测工具诊断下吧~（错误码：101)")
  if '150108' in content:
    print(f"网络已断开，可能原因：网络状态异常或账号已在别处登录，请稍后再试（20010009）")
  if '150109' in content:
    print(f"数据加密失败，请确认电脑上是否安装了共享软件并重启电脑（错误码：316）")
  if '150110' in content:
    print(f"设置域名解析服务器地址失败，请使用root帐号重试（错误码：317）")
  if '150200' in content:
    print(f"该帐号已于(%s)在其他机器上登录，如果这不是您的操作，您的宽带帐号可能已被盗用，请及时拨10000号申诉。（错误码：401）")
  if '150201' in content:
    print(f"用户账号受限。 (错误码：150201)")
  if '160001' in content:
    print(f"检测到共享软件冲突，受软件干扰网络已断开，请退出共享软件后重启客户端再连接。（错误码：402）")
  if '170001' in content:
    print(f"错误上报失败（错误码170001)")
  if '170001.0' in content:
    print(f"错误上报完成（错误码17000100)")
  if '170001.2' in content:
    print(f"获取上报权限失败（错误码17000102)")
  if '170001.3' in content:
    print(f"该帐号无上报权限，请联系维护人员获取帐号（错误码17000103)")
  if '170001.11' in content:
    print(f"获取错误文件失败（错误码17000111)")
  if '170001.12' in content:
    print(f"压缩错误文件失败（错误码17000112)")
  if '170001.13' in content:
    print(f"错误文件太大，无法上传（错误码17000113)")
  if '170001.14' in content:
    print(f"错误文件上传失败（错误码17000114)")
  if '170001.31' in content:
    print(f"请输入上报帐号（错误码17000131)")
  if '170001.32' in content:
    print(f"请不要重复上报（错误码17000132)")
  if '20010003' in content:
    print(f"配置文件被损坏，请重新安装客户端后再试。（错误码309）")
  if '20010004' in content:
    print(f"您已被其他终端/设备踢下线，请重新登录（错误码315）")
  if '20010101' in content:
    print(f"检测到与%s共享软件冲突，受软件干扰网络已断开，请退出共享软件后重启客户端再连接。(20010101)")
  if '20010102' in content:
    print(f"检测到与%s共享软件冲突，受软件干扰网络已断开，请退出共享软件后重启客户端再连接。(20010102)")
  if '20010103' in content:
    print(f"检测到与%s共享软件冲突，受软件干扰网络已断开，请退出共享软件后重启客户端再连接。(20010103)")
  if '20010104' in content:
    print(f"检测到隔离沙箱或虚拟机导致冲突，受软件干扰网络已断开，请在隔离沙箱或虚拟机外重启客户端再连接。(20010104)")
  if '20010105' in content:
    print(f"检测到共享冲突，受此干扰网络已断开，请关闭共享后重启客户端再连接。(20010105) ")
  if '20010201' in content:
    print(f"天翼校园拨号服务无法启动，请重新安装客户端后再试。（错误码310） ")
  if '20010202' in content:
    print(f"天翼校园拨号服务无法连接，请重新安装客户端后再试。（错误码311） ")
  if '20010203' in content:
    print(f"天翼校园拨号服务异常断开，请重新启动客户端。（错误码312） ")
  if '20010204' in content:
    print(f"(>﹏<)网络好像不通了，请确认网线是否被拔、无线是否被禁用（错误码：107） ")
  if '20010205' in content:
    print(f"(>﹏<)网络好像不通了，获取配置项未知错误。（错误码：108） ")
  if '20010206' in content:
    print(f"无法打开应急页面（错误码：20010206） ")
  if '20010207' in content:
    print(f"(>﹏<)连接客户端服务器失败，请重试。（错误码：109） ")
  if '20010208' in content:
    print(f"(>﹏<)请检查您的系统时间是否正确。（错误码：314） ")
  if '20010209' in content:
    print(f"服务启动超时，可能被第三方软件拦截，请卸载第三方软件后重试。（错误码320） ")
  if '20020200' in content:
    print(f"安全配置组件损坏，请重新安装客户端后再试。 ")
  if '20020200.1' in content:
    print(f"安全配置组件损坏，请重新安装客户端后再试。（错误码：600） ")
  if '20020200.2' in content:
    print(f"无法创建安全配置组件服务，请重启电脑重试。（错误码：601） ")
  if '20020200.3' in content:
    print(f"无法启动安全配置组件服务，请重启电脑重试。（错误码：602） ")
  if '20020200.4' in content:
    print(f"无法停止安全配置组件服务，请重启电脑重试。（错误码：603） ")
  if '20020200.5' in content:
    print(f"无法删除安全配置组件服务，请重启电脑重试。（错误码：604） ")
  if '20020200.6' in content:
    print(f"安全配置组件服务异常，请稍后重启客户端重试。（错误码：606） ")
  if '20020200.7' in content:
    print(f"安全配置组件服务异常，请稍后重启客户端重试。（错误码：607） ")
  if '20020200.8' in content:
    print(f"安全配置组件服务遭到破坏，请重新安装客户端后再试。（错误码：608） ")
  if '20020200.9' in content:
    print(f"安全配置组件服务异常，请稍后重启客户端重试。（错误码：609） ")
  if '20030200' in content:
    print(f"客户端组件遭到破坏，请重装客户端重试。（错误码：500） ")
  if '30000001' in content:
    print(f"拨号服务正在启动 ")
  if '30000002' in content:
    print(f"拨号服务正在更新 ")
  if '30000003' in content:
    print(f"拨号服务正在安装 ")
  if '30000004' in content:
    print(f"拨号服务状态启动正常 ")
  if '30000101' in content:
    print(f"网络状态检测中 ")
  if '30000102' in content:
    print(f"获取用户标识 ")
  if '30000103' in content:
    print(f"获取ip地址 ")
  if '30000104' in content:
    print(f"更新算法 ")
  if '30000105' in content:
    print(f"重新获取用户标识 ")
  if '30000106' in content:
    print(f"环境初始化中 ")
  if '40000001' in content:
    print(f"关闭后将退出提速，今日剩余提速时长也将清零，确认退出？ ")
  if '50000001' in content:
    print(f"账号不能为空 ")
  if '50000002' in content:
    print(f"密码不能为空 ")
  if '50000003' in content:
    print(f"二维码无法生成 ")

def get_current_date_str():
    """获取当前日期字符串，格式为 YYYYMMDD。"""
    return datetime.datetime.now().strftime("%Y%m%d")

def get_or_create_log_file():
    """获取或创建当天的日志文件路径。"""
    current_date_str = get_current_date_str()
    log_filename = f"{current_date_str}_Info.log"
    log_file_path = os.path.join(LOG_DIR, log_filename)
    
    # 如果文件不存在，则创建它
    if not os.path.exists(log_file_path):
        open(log_file_path, 'a').close()  # 创建空文件
    return log_file_path

#def start_monitoring_log_file(log_file_path):
#    """
#    开始监控日志文件的新内容，从文件的当前末尾开始。
#    
#    参数:
#    log_file_path -- 日志文件的路径。
#    """
#    with open(log_file_path, 'r') as log_file:
#        # 移动到文件末尾
#        log_file.seek(0, os.SEEK_END)
#        
#        # 读取新的内容
#        for line in log_file:
#            logging.info(f"日志文件: {line.strip()}")
#            # 这里调用之前定义的函数来解释错误码
#            explain_the_error_code(line.strip())

# #启动 ESurfingSvr 进程。
# def start_esurfing_svr(ESurfingSvr_account,ESurfingSvr_password):
#     #将变量 esurfing_svr_pid 全局化
#     global esurfing_svr_pid 
#     #对指令进行拼接
#     command = [ESURFING_SVR_PATH] + ' ' + ESurfingSvr_account + ' ' +ESurfingSvr_password
#     print(f"开始启动 ESurfingSvr。")
#     logging.info(f"执行命令： {command}")
#     logging.info(f'已从启动参数读取到以下信息：')
#     logging.info(f'账号: {args.account}')
#     logging.info(f'密码: {args.password}')
#     esurfing_svr_process = subprocess.Popen(command)
#     esurfing_svr_pid = esurfing_svr_process.pid
#     logging.info(f"ESurfingSvr 进程 ID: {esurfing_svr_pid}")

#使用系统 ping 命令 ping 指定主机。
def ping_host(host, count=1, timeout=DEFAULT_PING_TIMEOUT):
    try:
        # 使用 subprocess.run 执行系统 ping 命令
        if args.use_qemu:
            result = subprocess.run(
                ['/usr/bin/qemu-x86_64-static','/usr/bin/ping', '-c', str(count), '-W', str(timeout * 1000), host],
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

#多次 ping 指定主机列表。
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

# 启动ESurfingSvr进程并尝试捕获和打印输出
# def start_and_catch_esurfing_svr_output():
#     #避免奇奇怪怪的错误
#     process_exited = False
#     #定义log文件的路径
#     log_file_path = get_or_create_log_file()
    
#     # 打开日志文件
#     log_file = open(log_file_path, 'r')    #已只读模式打开日志文件
#     log_file.seek(0, os.SEEK_END)  # 移动到文件末尾
    
#     while True:
#         # 使用select.select监听子进程的stdout和stderr
#         #监听对象
#         #传入参数
#         #可读列表  可写列表。  异常列表   超时时间: 0.1s，即为0.1检查一下
#         #返回参数
#         #可都列表的信息 可写列表的信息 异常列表的信息
#         readable, _, _ = select.select([esurfing_svr_process.stdout, esurfing_svr_process.stderr, log_file], [], [], 0.1)
#         for stream in readable:
#             # 读取一行输出
#             output = stream.readline()
#             #如果没有两次读取之间没有产生新数据，会返回空字符
#             # 如果读取到空字符串且子进程已结束，跳出循环
#             if output == '' and esurfing_svr_process.poll() is not None:
#                  # 关闭文件
#                  log_file.close()
#                  esurfing_svr_process.stdout.close()
#                  esurfing_svr_process.stderr.close()
#                  process_exited = True  # 设置程序退出标志
#                  break
#             if output:
#                 # 根据输出来源打印不同的前缀，并检查特定关键词
#                 output_str = output.decode('utf-8').strip()
#                 if stream == esurfing_svr_process.stdout:
#                     logging.info(f"标准输出: {output_str}")
#                 elif stream == esurfing_svr_process.stderr:
#                     logging.error(f"错误输出: {output_str}")
#                 else:  # Log file
#                     logging.info(f"日志文件: {output_str}")
#                 explain_the_error_code(output_str)
#         # 如果子进程已结束，跳出循环
#         if process_exited:
#                 # 关闭文件
#             log_file.close()
#             esurfing_svr_process.stdout.close()
#             esurfing_svr_process.stderr.close()
#             break
#         time.sleep(1)
def start_and_catch_esurfing_svr_output():
    log_file_path = get_or_create_log_file()
    with open(log_file_path, 'r') as log_file:
        log_file.seek(0, os.SEEK_END)
        process_exited = False

        while True:
            readable, _, _ = select.select([esurfing_svr_process.stdout, esurfing_svr_process.stderr, log_file], [], [], 1)
            if not readable and esurfing_svr_process.poll() is not None: #检查是否子进程结束并且没有更多数据可读取
                process_exited = True
                break
            for stream in readable:
                output = stream.readline()
                if output:
                    output_str = output.decode('utf-8').strip()
                    if stream == esurfing_svr_process.stdout:
                        logging.info(f"标准输出: {output_str}")
                    elif stream == esurfing_svr_process.stderr:
                        logging.error(f"错误输出: {output_str}")
                    else:
                        logging.info(f"日志文件: {output_str}")
                    explain_the_error_code(output_str)
            if process_exited:
                break
            time.sleep(1)

#启动ESurfingSvr所用的函数
def start_esurfing_svr(ESurfingSvr_account, ESurfingSvr_password):
    # 构建启动命令，包括可执行文件路径和账号密码参数
    #使用 subprocess.Popen 时，不需要在代码中显式地添加空格来分隔命令和参数
    logging.info(f"正在启动 ESurfingSvr...")
    # 构建命令行参数
    if args.use_qemu:
        command = ['/usr/bin/qemu-x86_64-static',ESURFING_SVR_PATH, ESurfingSvr_account, ESurfingSvr_password]
    else:
        command = [ESURFING_SVR_PATH, ESurfingSvr_account, ESurfingSvr_password]
    # print("开始启动 ESurfingSvr。")
    # logging.info(f"执行命令： {' '.join(command)}")
    # logging.info(f'已从启动参数读取到以下信息：')
    # logging.info(f'账号: {ESurfingSvr_account}')
    # logging.info(f'密码: {ESurfingSvr_password}')
    
    # 启动ESurfingSvr进程，将stdout和stderr设置为PIPE以便捕获输出
    global esurfing_svr_process
    #不全局化的话，我都不知道该怎么定位子线程位置
    #args：shell命令
    #stdin, stdout, stderr：分别表示程序的标准输入、输出、错误句柄
    #bufsize：缓冲区大小。当创建标准流的管道对象时使用，默认-1。0：不使用缓冲区 1：表示行缓冲
    #text 为使用文本模式进行缓冲
    #缓冲区(buffer)，它是内存空间的一部分。
    esurfing_svr_process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
    
    # 开启子线程
    #thread.start_new_thread ( function, args[, kwargs] )
    #参数说明:
    #function - 线程函数。
    #args - 传递给线程函数的参数,他必须是个tuple类型。
    #kwargs - 可选参数。
    #启动子函数 start_and_catch_esurfing_svr_output
    catch_esurfing_svr_output = threading.Thread(target=start_and_catch_esurfing_svr_output)
    catch_esurfing_svr_output.daemon = True  # 设置为守护线程，当主程序退出时子线程也退出
    #启动子线程并开始捕获输出
    catch_esurfing_svr_output.start()
    #传递pid到esurfing_svr_pid
    esurfing_svr_pid = esurfing_svr_process.pid
    logging.info(f"已启动 ESurfingSvr ")
    logging.info(f"ESurfingSvr  PID: {esurfing_svr_pid}")
    #开始检查网络连接情况
    NETWORK_AUTH_start_time=time.time()
    while time.time() - NETWORK_AUTH_start_time < DEFAULT_NETWORK_AUTH_TIMEOUT :
        NETWORK_AUTH_TIMEOUT_result = multi_ping()
        if NETWORK_AUTH_TIMEOUT_result:
            logging.info(f"成功完成ping操作。")
            logging.info(f"网络认证成功。")
            current_ips = get_ip_addresses()
            return True
            break  # 如果multi_ping()返回True，则中断循环
        time.sleep(1)  # 每次循环等待1秒

    if not NETWORK_AUTH_TIMEOUT_result:
        logging.error("错误：无法完成网络认证")
        return False

#用于强制结束 ESurfingSvr
def force_shutdown_esurfing_svr(ESURFINGSRV_CLOSE_WAITTIME=5):
    esurfing_svr_process.terminate()  # 发送终止信号
    force_shutdown_esurfing_svr_stop_start_time=time.time()
    # time.sleep(ESURFINGSRV_CLOSE_WAITTIME)  #等待 esurfing_svr_close_timeout 时间
    while time.time() - force_shutdown_esurfing_svr_stop_start_time < ESURFINGSRV_CLOSE_WAITTIME:
        if esurfing_svr_process.poll() is None:
            # 子进程仍在运行
            logging.info(f"ESurfingSvr仍在运行。继续等待。")
        else:
            # 子进程已经结束
            print("ESurfingSvr已经结束运行。")
            break   #提前break，避免长时间的等待
        time.sleep(1)
    if esurfing_svr_process.poll() is None:  # 如果进程仍未结束
                logging.info(f"进程未响应关闭信号，正在强制关闭...")
                esurfing_svr_process.kill()  # 强制关闭进程
    #esurfing_svr_process.wait()  # 等待进程结束
    logging.info(f"程序已关闭。")

#获取所有网卡的 IP 地址。
def get_ip_addresses():
    ip_addresses = []
    for interface, addresses in psutil.net_if_addrs().items():
        for address in addresses:
            if address.family == socket.AF_INET:
                ip_addresses.append(address.address)
    logging.debug(f"成功获取当前设备的所有ip地址：{ip_addresses}")
    return ip_addresses

#处理信号，确保程序可以正确退出。
def signal_handler(sig, frame):
    logging.info(f"收到终止信号，正在关闭程序...")
    force_shutdown_esurfing_svr()
    logging.info(f"程序已关闭。")
    exit(0)

def monitor_ping():
    if multi_ping():
        logging.info(f"PING成功！")
        return True
    else:
        logging.error("PING失败")
        return False

def restart_esurfing_svr():
    #尝试关闭进程
    logging.info(f"正在关闭EsurfingEvr")
    force_shutdown_esurfing_svr()
    time.sleep(ESURFINGSRV_RESTART_WAITTIME)
    logging.info(f"正在重启EsurfingEvr")
    # 启动 ESurfingSvr
    if start_esurfing_svr(args.account,args.password):
      logging.info(f"ESurfingSvr 启动完成。")
    else:
      logging.info(f"超时未能完成网络认证。")
      exit(0)
    
def check_PING():
    if monitor_ping():
        logging.info(f"定时PING成功，网络可以正常使用.")
    else:
        logging.info(f"定时PING失败，尝试重启")
        restart_esurfing_svr()

def CHECK_IP():
    NO_IP_time=0
    while NO_IP_time < DEFAULT_MAX_NO_IP_COUNT:
        if get_ip_addresses() == '':
            logging.info(f"获取当前IP失败，或者没有网卡可以用于获取IP")
            NO_IP_time=NO_IP_time+1
            restart_esurfing_svr()
            time.sleep(DEFAULT_WAIT_AFTER_NO_IP)
        else:
            if current_ips == get_ip_addresses():
                logging.info(f"IP地址没有发送变化")
                Next_check_ip_time=time.time()+DEFAULT_MONITOR_IP_INTERVAL
                break
            else:
                time.sleep(DEFAULT_WAIT_AFTER_IP_CHANGE)
                if multi_ping():
                    logging.info(f"PING成功，网络仍然可以正常使用。")
                    Next_check_ping_time=time.time()+DEFAULT_MONITOR_PING_INTERVAL
                    Next_check_ip_time=time.time()+DEFAULT_MONITOR_IP_INTERVAL
                    current_ips == get_ip_addresses()
                else:
                    logging.info(f"PING失败，尝试重启")
                    restart_esurfing_svr()

def Check_process():
  if esurfing_svr_process.poll() is None:
    # 子进程仍在运行
    logging.info(f"ESurfingSvr仍在运行。")
    return True
  else:
    # 子进程已经结束
    logging.info(f"ESurfingSvr已经结束运行。")
    return False

def CHeck_Process_Activing():
    poll_result = esurfing_svr_process.poll()
    if poll_result is None:
        # 子进程仍在运行
        logging.info(f"ESurfingSvr仍在运行。")
        return True
    elif poll_result == 0:
        # 子进程正常退出
        logging.warning("ESurfingSvr正常退出。")  # Use warning level for normal exit
        return False
    else:
        # 子进程异常退出
        logging.error(f"ESurfingSvr异常退出，返回代码: {poll_result}")
        return False

def Check_process():
    if CHeck_Process_Activing:
        logging.info(f"ESurfingSvr仍在运行。")
    else:
        logging.info(f"ESurfingSvr已结束运行。尝试重启")
        restart_esurfing_svr()

#确保中国电信客户端还活着
def monitor():
    Next_check_ping_time=time.time()+DEFAULT_MONITOR_PING_INTERVAL
    Next_check_ip_time=time.time()+DEFAULT_MONITOR_IP_INTERVAL
    while True:
        if Next_check_ping_time - time.time() < 0 and DEFAULT_MONITOR_IP_INTERVAL- time.time() >=0:
            check_PING()
            # Check_process()
                
        elif Next_check_ping_time - time.time() >= 0 and DEFAULT_MONITOR_IP_INTERVAL- time.time() <0:
            CHECK_IP()
            # Check_process()
        
        elif Next_check_ping_time - time.time() < 0 and DEFAULT_MONITOR_IP_INTERVAL- time.time() <0:
            CHECK_IP()
            check_PING()
            # Check_process()
        time.sleep(1)
        # Check_process()

def signal_handler(signum, frame):
    logging.info(f"检测到有子进程退出，检测是否为ESurfingSvr 进程")
    Check_process()

#定义主循环函数
def main():
    # # 解析命令行参数
    # parser = argparse.ArgumentParser()
    # parser.add_argument("args", nargs="*", help="传递给 ESurfingSvr 的参数")
    # args = parser.parse_args()
    # ARGS = args.args

    # 创建 ArgumentParser 对象
    # description - 在参数帮助文档之前显示的文本（默认值：无）
    # add_help - 为解析器添加一个 -h/--help 选项（默认值： True）
    # epilog - 在参数帮助文档之后显示的文本（默认值：无）
    parser = argparse.ArgumentParser(description='传递给 ESurfingSvr （中国电信官方客户端） 所进行ZSM验证需要的参数',add_help=True,epilog="示例: 13888888888 123456")

    # name - 一个命名
    # help - 一个此选项作用的简单描述。
    # 添加账号参数
    parser.add_argument('account', help='进行ZSM验证所用的用户名（一般为手机号）')
    # 添加密码参数
    parser.add_argument('password', help='进行ZSM验证所用的密码（一般为手机号后八位）')

    #被迫使用qemu来解析中国电信Linux客户端
    parser.add_argument("--use_qemu", action='store_true', help="是否使用QEMU (默认为False)")
    global args #全局化变量

    # 解析命令行参数
    args = parser.parse_args()

    # 注册信号处理函数
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGCHLD, signal_handler)  # 注册 SIGCHLD 信号处理程序
    global ESurfingSvr_account
    global ESurfingSvr_password
    ESurfingSvr_account={args.account}
    ESurfingSvr_password={args.password}
    # 打印输入的账号和密码
    # 特别提醒，python在print之后会自动添加一个\n进行换行
    # logging.info(f'已从启动参数读取到以下信息：')
    # logging.info(f'账号: {args.account}')
    # logging.info(f'密码: {args.password}')

    #添加默认标记
    global esurfing_svr_pid
    global current_ips
    current_ips= None
    global process_exited
    esurfing_svr_pid = None  # 用于存储ESurfingSvr进程ID的全局变量
    process_exited = False  # 用于标记程序是否已经退出执行
    global network_authenticated    #用于标记网络是否已经完成认证
    network_authenticated = False

    # 启动 ESurfingSvr
    if start_esurfing_svr(args.account, args.password):
      logging.info(f"ESurfingSvr 启动完成。")
    else:
      logging.info(f"超时未能完成网络认证。")
      exit(0)

    #开始进入监视
    monitor()

if __name__ == "__main__":
    main()
