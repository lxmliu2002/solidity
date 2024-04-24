import os
import shutil

source_code_folder = "/mnt/data/chenlongfei/liuxm/solidity/solidity/newnew/codes"
destination_folder = "/mnt/data/chenlongfei/liuxm/solidity/solidity/newnew/jsons"
json_folder = "/mnt/data/chenlongfei/Tool/sol_batch_compile-main/compiled_info"

source_code_list = [subfolder for subfolder in os.listdir(source_code_folder) if os.path.isdir(os.path.join(source_code_folder, subfolder))]
json_list = [file for file in os.listdir(json_folder) if os.path.isfile(os.path.join(json_folder, file))]

for source_code_item in source_code_list:
    source_code_prefix = source_code_item.split("_")[0]
    for json_file in json_list:
        json_prefix = json_file.split("_")[0]
        if source_code_prefix == json_prefix:
            source_path = os.path.join(json_folder, json_file)
            destination_path = os.path.join(destination_folder, json_file)
            shutil.copyfile(source_path, destination_path)
