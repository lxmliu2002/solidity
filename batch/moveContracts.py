import os
import shutil
from tqdm import tqdm
import random
# 源文件夹路径
source_dir = '../etherscan-contract-crawler/contracts'

# 目标文件夹路径
destination_dir = './contracts'
def random_move():
    # 获取源文件夹中的所有文件
    _files = os.listdir(source_dir)
    # _files.sort()
    # 排序文件列表
    files = [i for i in _files if not i.endswith('.json')]
    # 获取前1000个文件
    # random.seed(404)
    # files_to_move = random.sample(files[1000:], 50)

    files_to_move = files[:1000]

    # 移动文件到目标文件夹
    for file in tqdm(files_to_move):
        source_file_path = os.path.join(source_dir, file)
        destination_file_path = os.path.join(destination_dir, file)
        shutil.copytree(source_file_path, destination_file_path)

def move_onedir():
    one_dir = './example_check'
    file = '0xF8fe6fA0D9c778F8d814c838758B57a9Cf1dD710_ColdPath'
    source_file_path = os.path.join(source_dir, file)
    destination_file_path = os.path.join(one_dir, file)
    shutil.copytree(source_file_path, destination_file_path)

def move_error():
    err_dir = './error_info'
    files = os.listdir(err_dir)
    for _file in tqdm(files):
        file = _file[:-4]
        source_file_path = os.path.join(source_dir, file)
        destination_file_path = os.path.join(destination_dir, file)
        shutil.copytree(source_file_path, destination_file_path)

# random_move()
# move_error()
move_onedir()