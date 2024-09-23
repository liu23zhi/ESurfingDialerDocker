import requests
from bs4 import BeautifulSoup
import re
import os
import tarfile
import shutil
import sys

def delete_existing_files_and_folders(file_name, folder_name):
    print(f"检查文件：{file_name} 和文件夹：{folder_name} 是否存在...")
    if os.path.exists(file_name):
        os.remove(file_name)
        print(f"已删除文件：{file_name}")
    else:
        print(f"文件：{file_name} 不存在，无需删除")

    if os.path.exists(folder_name):
        shutil.rmtree(folder_name)
        print(f"已删除文件夹：{folder_name}")
    else:
        print(f"文件夹：{folder_name} 不存在，无需删除")

def download_file(url, local_filename):
    print(f"检查文件：{local_filename} 是否已存在...")
    if not os.path.exists(local_filename):
        print(f"文件不存在，开始下载：{url}")
        try:
            with requests.get(url, stream=True) as r:
                r.raise_for_status()
                print(f"请求成功，状态码：{r.status_code}")
                with open(local_filename, 'wb') as f:
                    downloaded = 0
                    total_length = int(r.headers.get('content-length', 0))
                    print("下载中...")

                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
                            downloaded += len(chunk)
                            done = int(50 * downloaded / total_length)
                            bar = "█" * done + "-" * (50-done)
                            print(f"\r|{bar}| {done * 2}%", end="")

                    print("\n下载完成")
                print(f"文件已下载到：{local_filename}")
        except requests.exceptions.HTTPError as errh:
            print(f"HTTP错误：{errh}")
            sys.exit(1)
        except requests.exceptions.ConnectionError as errc:
            print(f"连接错误：{errc}")
            sys.exit(1)
        except requests.exceptions.Timeout as errt:
            print(f"超时错误：{errt}")
            sys.exit(1)
        except requests.exceptions.RequestException as err:
            print(f"发生了其他错误：{err}")
            sys.exit(1)
    else:
        print(f"文件 {local_filename} 已存在，跳过下载。")

def get_linux_64_download_link(url):
    print("正在获取网页内容...")
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
        }
        print(f"正在使用UA：{headers['User-Agent']}")
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        print(f"请求成功，状态码：{response.status_code}")

        encoding = response.encoding if 'charset' in response.headers.get('content-type', '').lower() else 'utf-8'
        content = response.content.decode(encoding, errors='ignore')
        soup = BeautifulSoup(content, 'html.parser')

        print("正在解析网页...")
        links = soup.find_all('a', string=re.compile(r'linux 64', re.IGNORECASE))
        if not links:
            print("没有找到包含'linux 64'的下载链接。")
            sys.exit(1)

        for link in links:
            download_url = link.get('href')
            if download_url:
                print(f"找到下载链接：{download_url}")
                local_filename = 'ESurfingDialerClient.tar.gz'
                download_file(download_url, local_filename)
                return download_url
        print("没有找到有效的下载链接。")
        sys.exit(1)
    except requests.exceptions.HTTPError as errh:
        print(f"HTTP错误：{errh}")
        sys.exit(1)
    except requests.exceptions.ConnectionError as errc:
        print(f"连接错误：{errc}")
        sys.exit(1)
    except requests.exceptions.Timeout as errt:
        print(f"超时错误：{errt}")
        sys.exit(1)
    except requests.exceptions.RequestException as err:
        print(f"发生了其他错误：{err}")
        sys.exit(1)

def extract_tar_gz(tar_path, extract_path):
    print(f"解压文件：{tar_path} 到路径：{extract_path}")
    try:
        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(path=extract_path)
        print(f"文件已解压到：{extract_path}")
    except tarfile.TarError as e:
        print(f"\n解压错误：{e}")
        sys.exit(1)

def check_and_move_files(target_dir, extract_path, files_to_find):
    print(f"检查并移动文件：{files_to_find} 从：{target_dir} 到：{extract_path}")
    all_files_found = True
    for file_name in files_to_find:
        file_path = os.path.join(extract_path, file_name)
        if os.path.exists(file_path):
            print(f"\n{file_name} 已经在目标路径 {extract_path} 中存在。")
        else:
            found = False
            for root, dirs, files in os.walk(target_dir):
                if file_name in files:
                    subfolder = root  # 包含目标文件的子文件夹路径
                    print(f"\n在子文件夹 {subfolder} 中找到 {file_name}")
                    found = True
                    # 移动子文件夹内的所有内容到目标目录
                    for sub_root, sub_dirs, sub_files in os.walk(subfolder):
                        for file in sub_files:
                            src_file_path = os.path.join(sub_root, file)
                            rel_path = os.path.relpath(src_file_path, start=subfolder)
                            dest_file_path = os.path.join(extract_path, rel_path)
                            print(f"移动文件：{src_file_path} -> {dest_file_path}")
                            if not os.path.exists(os.path.dirname(dest_file_path)):
                                os.makedirs(os.path.dirname(dest_file_path))
                            shutil.move(src_file_path, dest_file_path)
                    # 删除原子文件夹
                    shutil.rmtree(subfolder)
                    print(f"已删除原子文件夹：{subfolder}")
                    break  # 找到文件后停止搜索
            if not found:
                print(f"{file_name} 没有找到")
                all_files_found = False
    if not all_files_found:
        sys.exit(1)

def main():
    # url = 'http://zsteduapp.10000.gd.cn/More/linuxDownLoad/linuxDownLoad.html'
    url = 'http://14.146.226.81/More/linuxDownLoad/linuxDownLoad.html'
    file_name = 'ESurfingDialerClient.tar.gz'
    folder_name = './ESurfingDialerClient'

    # 删除同名文件和文件夹
    delete_existing_files_and_folders(file_name, folder_name)

    # 获取下载链接
    download_url = get_linux_64_download_link(url)
    if download_url:
        # 下载文件
        local_filename = 'ESurfingDialerClient.tar.gz'
        download_file(download_url, local_filename)

        # 解压文件
        extract_path = './ESurfingDialerClient'
        extract_tar_gz(local_filename, extract_path)

        # 检查并移动文件夹内的所有内容
        files_to_find = ['client', 'ESurfingSvr', 'tyxy']
        check_and_move_files(folder_name, extract_path, files_to_find)

if __name__ == "__main__":
    main()
