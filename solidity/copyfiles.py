import os
import shutil
import random

def copy_random_folders(source_path, destination_path, num_folders=10):
    # 获取当前路径下所有文件夹
    folders = [folder for folder in os.listdir(source_path) if os.path.isdir(os.path.join(source_path, folder))]
    
    # 从中随机选取num_folders个文件夹
    selected_folders = random.sample(folders, min(num_folders, len(folders)))
    
    # 将选中的文件夹复制到目标路径下
    for folder in selected_folders:
        source_folder = os.path.join(source_path, folder)
        destination_folder = os.path.join(destination_path, folder)
        shutil.copytree(source_folder, destination_folder)
        print(f"Folder '{folder}' copied to '{destination_folder}'")

# 指定当前路径和目标路径
current_path = "/mnt/data/chenlongfei/Tool/sol_batch_compile-main/contracts"
destination_path = "/mnt/data/chenlongfei/liuxm/solidity/solidity/newnew/codes"

# 调用函数复制文件夹
copy_random_folders(current_path, destination_path)
