import json

def remove_empty_or_short_entries(json_data):
    """
    递归地移除JSON数据中所有不满足最小长度1的数组或字典值。
    
    参数:
    json_data (dict or list): 要处理的JSON数据，可以是字典或列表。
    
    返回:
    dict or list: 移除了不满足条件的键值对后的新JSON数据。
    """
    def remove_empty_or_short(obj):
        """
        递归地检查并移除不满足条件的键值对或元素。
        """
        if isinstance(obj, dict):
            # 使用字典推导式创建一个新的字典，只包含满足条件的键值对
            obj = {k: remove_empty_or_short(v) for k, v in obj.items() if should_keep(k, v)}
            # 如果字典为空，则返回None
            if not obj:
                return None
            return obj
        elif isinstance(obj, list):
            # 使用列表推导式创建一个新的列表，只包含满足条件的元素
            obj = [remove_empty_or_short(item) for item in obj if should_keep(None, item)]
            # 如果列表为空，则返回None
            if not obj:
                return None
            return obj
        else:
            # 基础类型（如字符串、数字）直接返回
            return obj

    def should_keep(key, value):
        """
        判断一个键值对或元素是否应该被保留。
        
        参数:
        key (str): 键名，对于列表元素，此参数为None。
        value (any): 键值对的值或列表的元素。
        
        返回:
        bool: 如果值应该被保留，则返回True；否则返回False。
        """
        # 如果是字典，检查值是否为空或None
        if isinstance(value, dict) and not value:
            return False
        # 如果是列表，检查长度是否小于1
        if isinstance(value, list) and len(value) < 1:
            return False
        # 如果是字符串，检查长度是否小于1
        if isinstance(value, str) and len(value) < 1:
            return False
        return True

    # 开始递归处理JSON数据
    return remove_empty_or_short(json_data)

def process_json_file(input_file, output_file):
    """
    处理JSON文件，移除不满足最小长度1的数组或字典值，并将结果写入新文件。
    
    参数:
    input_file (str): 输入JSON文件的路径。
    output_file (str): 输出JSON文件的路径。
    """
    try:
        with open(input_file, 'r', encoding='utf-8') as file:
            # 读取JSON文件并解析为Python对象
            json_data = json.load(file)
        
        # 移除不满足最小长度1的数组或字典值
        cleaned_json_data = remove_empty_or_short_entries(json_data)
        
        # 将清理后的JSON数据写入新文件
        with open(output_file, 'w', encoding='utf-8') as file:
            # 将Python对象序列化为JSON字符串，并写入文件
            json.dump(cleaned_json_data, file, indent=4)
        
        print(f"Processed file saved as {output_file}")
    except FileNotFoundError:
        print(f"The file {input_file} does not exist.")
    except json.JSONDecodeError:
        print(f"The file {input_file} is not a valid JSON file.")
    except Exception as e:
        print(f"An error occurred: {e}")

# 输入的文件
input_file = 'megalinter-report.sarif'
# 输出的文件
output_file = 'megalinter-report-sarif.json'
process_json_file(input_file, output_file)