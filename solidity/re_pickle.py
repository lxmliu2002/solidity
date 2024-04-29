import os
import pickle
import json
from tqdm import tqdm

def process_files(root_dir, pickle_dir):
    sol_files_dict = {}
    num = 0
    before_length = 0
    after_length = 0
    json_data = {}

    # 获取文件总数以显示进度条
    total_files = sum(len(files) for _, _, files in os.walk(root_dir))

    with tqdm(total=total_files, desc="Processing files") as pbar:
        for root, dirs, files in os.walk(root_dir):
            for file in files:
                if file.startswith("lxmdelete"):
                    file_path = os.path.join(root, file)
                    filename = os.path.basename(os.path.dirname(file_path))

                    complete_file_path = os.path.join(root, "lxmcomplete")
                    if os.path.exists(complete_file_path):
                        with open(complete_file_path, "r") as f_complete:
                            complete_content = f_complete.read()
                        before_length += len(complete_content)
                    else:
                        pbar.update(1)  # 更新进度条
                        continue

                    with open(file_path, "r") as f:
                        content = f.read()
                    sol_files_dict[filename] = content

                    num += 1
                    after_length += len(content)

                    if len(sol_files_dict) == 100000:
                        json_data.update(save_dict(pickle_dir, sol_files_dict, num, before_length, after_length))
                        sol_files_dict.clear()
                        before_length = 0
                        after_length = 0

                    try:
                        os.remove(file_path)
                        os.remove(complete_file_path)
                    except:
                        pass

                    pbar.update(1)  # 更新进度条

    if sol_files_dict:
        json_data.update(save_dict(pickle_dir, sol_files_dict, num, before_length, after_length))

    with open(os.path.join(pickle_dir, 'details.json'), 'w') as f:
        json.dump(json_data, f, indent=4)

def save_dict(pickle_dir, dictionary, num, before_length, after_length):
    filename = 'sol_code_' + str(num) + '.pickle'
    pickle_path = os.path.join(pickle_dir, filename)
    with open(pickle_path, "wb") as f:
        pickle.dump(dictionary, f)
    return {
        filename: {
            "before_avg_len": before_length / len(dictionary),
            "after_avg_len": after_length / len(dictionary)
        }
    }

# 指定要遍历的文件目录
root = "/mnt/data/chenlongfei/liuxm/solidity/solidity/contracts/codes"
pickle_dir = "/mnt/data/chenlongfei/liuxm/solidity/solidity/pickle_files"

# 开始处理文件
process_files(root, pickle_dir)
