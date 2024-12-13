import requests
import argparse
import os

#GitHub仓库路径
Github_Repositorie= "Rsplwe/ESurfingDialer"
#Release版本
Github_Repositorie_Version= "latest"
# GitHub备用访问令牌
access_token = ""
#Github Api请求Url
api_url = "https://api.github.com/"

#合成对应的请求URl
Github_Repositorie_Release = api_url + "repos/" + Github_Repositorie + "/releases/" + Github_Repositorie_Version

def getdownload(access_token):

    # 发送GET请求到API URL，包含身份验证
    headers = {'Authorization': f'token {access_token}'}
    response = requests.get(Github_Repositorie_Release, headers=headers)

    # 输出HTTP响应状态码以进行调试
    print(f"HTTP响应状态码: {response.status_code}")

    # 检查请求是否成功
    if response.status_code == 200:
        # 解析JSON响应
        latest_release = response.json()
        
        # 查找jar文件的下载链接
        jar_asset = next((asset for asset in latest_release['assets'] if asset['name'].endswith('.jar')), None)
        
        if jar_asset:
            download_url = jar_asset['browser_download_url']
            print(f"下载URL: {download_url}")
            return download_url
        else:
            print("未找到jar文件的下载链接")
            return "error"
    else:
        print("获取release信息失败")
        print(f"响应内容: {response.text}")  # 输出响应内容以进行调试
        return "error"

def download_file(url, local_filename):
    #下载文件函数
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
        except requests.exceptions.ConnectionError as errc:
            print(f"连接错误：{errc}")
        except requests.exceptions.Timeout as errt:
            print(f"超时错误：{errt}")
        except requests.exceptions.RequestException as err:
            print(f"发生了其他错误：{err}")
        except Exception as e:
            print(f"发生了未知错误：{e}")
    else:
        print(f"文件 {local_filename} 已存在，跳过下载。")

if __name__ == "__main__":
    # 创建 ArgumentParser 对象
    # description - 在参数帮助文档之前显示的文本（默认值：无）
    # add_help - 为解析器添加一个 -h/--help 选项（默认值： True）
    # epilog - 在参数帮助文档之后显示的文本（默认值：无）
    parser = argparse.ArgumentParser(description='用于获取Release最新Jar所需的个人令牌',add_help=True,epilog="示例:--token 123456789")

    # name - 一个命名
    # help - 一个此选项作用的简单描述。
    # 添加token参数
    parser.add_argument('--token', help='用于获取Release最新Jar所需的个人令牌')
    # 解析传入参数
    args = parser.parse_args()
    
    if args.token == None:
        print(f"输入的token为空！")
        print(f"请在--token 后填写token，例如\"--token 123\"")
        if  access_token != "":
            Github_Token=access_token
        else :
            print(f"程序无法运行!")
            exit(1)
    else:
        Github_Token=args.token
        
    # print(f"{Github_Repositorie_Release}")
    Jar_Download_Url=getdownload(Github_Token)
    if Jar_Download_Url != "error" :
        download_file(Jar_Download_Url,"ESurfingDialer_Releae_By_Original_Author.jar")