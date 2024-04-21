import os
import random
import shutil

def copy_random_files(source_folder, destination_folder, num_files):
    all_files = os.listdir(source_folder)

    selected_files = random.sample(all_files, min(num_files, len(all_files)))

    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    for file_name in selected_files:
        source_path = os.path.join(source_folder, file_name)
        destination_path = os.path.join(destination_folder, file_name)
        shutil.copy2(source_path, destination_path)
        print(f"Copying {file_name} to {destination_folder}")


source_folder_path = '/mnt/data/chenlongfei/Tool/sol_batch_compile-main/compiled_info'
# destination_folder_path = '/mnt/data/chenlongfei/Tool/Decompile/test_sols'
destination_folder_path = '/mnt/data/chenlongfei/liuxm/compiler/test/testfiles'
num_files_to_copy = 5

copy_random_files(source_folder_path, destination_folder_path, num_files_to_copy)
