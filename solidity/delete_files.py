import os

def delete_files_with_prefix(root_folder, prefix_list):
    for root, dirs, files in os.walk(root_folder):
        for file in files:
            for prefix in prefix_list:
                if file.startswith(prefix):
                    file_path = os.path.join(root, file)
                    os.remove(file_path)
                    print(f"Deleted: {file_path}")


root_folder = "/mnt/data/chenlongfei/liuxm/solidity/solidity/contracts/codes"

prefix_list = ["complete", "delete"]

delete_files_with_prefix(root_folder, prefix_list)
