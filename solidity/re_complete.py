import os
import re
import json
from tqdm import tqdm
import time
import timeout_decorator
import multiprocessing
import traceback
from functools import partial


def delete_comments(allstr):
    allstrs = allstr.split("\n")
    mark = 1
    newstr = ""
    for str in allstrs:
        strs = str.split("\"")
        for i in range(len(strs)):
            if mark == 0:
                if strs[i].find("*/") !=-1:
                    ss = strs[i].split("*/")
                    if len(ss) >= 1:
                        newstr += ss[1]
                    mark = 1
                    continue
                else:
                    continue
            if i % 2 == 0 and mark == 1:
                if strs[i].find("//") !=-1:
                    ss = strs[i].split("//")
                    newstr += ss[0]
                    break
                if strs[i].find("/*") !=-1:
                    ss = strs[i].split("/*")
                    newstr += ss[0]
                    if strs[i].find("*/") !=-1:
                        ss2 = ss[1].split("*/")
                        newstr += ss2[1]
                    else:
                        mark = 0
                    continue
            newstr += strs[i]
            if i != len(strs)-1 : newstr += "\""
        newstr += "\n"
    return newstr

def check_sol_files(directory):
    """Check for Solidity files in the given directory."""
    return [filename for filename in os.listdir(directory) if filename.endswith('.sol')]

def get_filename(path):
    """Extract and filename from metadata or inpage_meta files."""
    filename = None
    try:
        if os.path.exists(os.path.join(path, "metadata.json")):
            with open(os.path.join(path, "metadata.json"), 'r') as f:
                content = json.load(f)
                filename = content["contract_name"]
        if filename is not None:
            return filename
        if os.path.exists(os.path.join(path, "inpage_meta.json")):
            with open(os.path.join(path, "inpage_meta.json"), 'r') as f:
                content = json.load(f)
                filename = content["contract_name"]
                if any(item.endswith("_" + filename + ".sol") for item in os.listdir(path)):
                    filename = [item for item in os.listdir(path) if item.endswith("_" + filename + ".sol")][0]
                if not filename.endswith(".sol"):
                    filename += ".sol"
    except:
        pass
    return filename

def handle_error(e, p, filename=None):
    """Handle errors and write traceback to a file."""
    with open(os.path.join("/mnt/data/chenlongfei/liuxm/solidity/solidity/error", p + ".log"), "w") as file:
        file.write(traceback.format_exc())

def get_contents(input_file_path):
    pattern_pragma = r'pragma\s+solidity\s+(.*);'
    pattern_import = r"import\s+[\'\"](.+?)[\'\"]\;"
    pattern_from = r"import\s*{.*}\s*from\s*[\'\"](.+?)[\'\"]\;"
    
    with open(input_file_path, 'r') as f:
        data = f.read()
    data = re.sub(pattern_import, '', data)
    data = re.sub(pattern_pragma, '', data)
    data = re.sub(pattern_from, '', data)
    data = delete_comments(data)
    data = "\n".join([i for i in data.split("\n") if i.strip() != ""])
    
    data += '\n'
    return data

def limit_recursion_depth(max_depth):
    def decorator(func):
        current_depth = 0

        def wrapper(*args, **kwargs):
            nonlocal current_depth
            if current_depth >= max_depth:
                raise RecursionError("Recursion depth exceeded")
            current_depth += 1
            try:
                return func(*args, **kwargs)
            finally:
                current_depth -= 1
        return wrapper
    return decorator

# @timeout_decorator.timeout(50, use_signals=True)
@limit_recursion_depth(30)
def file_import(filepath, G:dict = None, original_dict:dict = None, delete_dict:dict = None):
    if G is None:
        G = {}
    if original_dict is None:
        original_dict = {}
    if delete_dict is None:
        delete_dict = {}
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = f.read()
        pattern_import = r"import\s+[\'\"](.+?)[\'\"]\;"
        pattern_from = r"import\s*{.*}\s*from\s*[\'\"](.+?)[\'\"]\;"
        
        file_name = os.path.basename(filepath)
        # print(file_name)
        if file_name not in G:
            G[file_name] = []
        if file_name not in original_dict:
            matches = re.findall(pattern_import + '|' + pattern_from, data)
            need_add_import = []
            for match in matches:
                if match[0]:
                    matchname = match[0]
                else:
                    matchname = match[1]

                matchpath = os.path.join(os.path.dirname(filepath), matchname[2:])
                if os.path.exists(matchpath):
                    file_import(matchpath, G, original_dict, delete_dict)
                if matchname not in G[file_name]:
                    G[file_name].append(matchname)
                if match[1] and matchname not in need_add_import:
                    need_add_import.append(matchname[2:])

                
            original_dict[file_name] = get_contents(filepath)
            delete_dict[file_name] = get_contents(filepath)

            if need_add_import:
                tmp:str = ""
                for name in need_add_import:
                    tmp = tmp + delete_dict[name]
                    del delete_dict[name]
                delete_dict[file_name] = tmp + delete_dict[file_name]

    except Exception as e:
        pass
    
    return G, original_dict, delete_dict
    

def get_version(input_file, output_file):
    pattern = r'pragma\s+solidity\s+(.*);'
    with open(input_file, 'r') as f:
        content = f.read()

    matches = re.finditer(pattern, content)
    with open(output_file, 'w') as matched_f:
        last_end = 0
        for match in matches:
            start_index = match.start()
            matched_content = match.group(0)
            preceding_content = content[last_end:start_index]
            matched_f.write(preceding_content + matched_content + '\n')
            break

def process_directory(source_code_folder):
    for p in tqdm(os.listdir(source_code_folder)):
        path = os.path.join(source_code_folder, p)
        try:
            if not check_sol_files(path):
                raise FileNotFoundError("Error: No contracts found.")
            filename = get_filename(path)
            output_filename = "lxmcomplete"
            filepath = os.path.join(path, filename)
            out_filepath = os.path.join(path, output_filename)
            
            get_version(filepath, out_filepath)
            
            G, original_dict, delete_dict = file_import(filepath)
            with open(out_filepath, 'a') as f:
                for file_name, contents in delete_dict.items():
                    f.write(contents)
            
        except FileNotFoundError as e:
            handle_error(e, p)
        except Exception as e:
            handle_error(e, p)

def multi_process_directory(source_code_folder, p):

    path = os.path.join(source_code_folder, p)
    try:
        if not check_sol_files(path):
            raise FileNotFoundError("Error: No contracts found.")
        filename = get_filename(path)
        output_filename = "lxmcomplete"
        filepath = os.path.join(path, filename)
        out_filepath = os.path.join(path, output_filename)
        
        get_version(filepath, out_filepath)
        
        G, original_dict, delete_dict = file_import(filepath)
        with open(out_filepath, 'a') as f:
            for file_name, contents in delete_dict.items():
                f.write(contents)
        
    except FileNotFoundError as e:
        handle_error(e, p)
    except Exception as e:
        handle_error(e, p)

if __name__ == "__main__":
    st = time.time()
    
    source_code_folder = '/mnt/data/chenlongfei/liuxm/solidity/solidity/contracts/codes'
    num_processes = 56
    
    # process_directory(source_code_folder)
    
    with multiprocessing.Pool(processes=num_processes) as pool:
        process_func = partial(multi_process_directory, source_code_folder)
        list(tqdm(pool.imap(process_func, [p for p in os.listdir(source_code_folder)]), total = len(os.listdir(source_code_folder))))
        pool.close()
        pool.join()

    ed = time.time()
    print("Total Time Cost:",ed - st)
    print("Average Time Cost:", (ed - st) / len(os.listdir(source_code_folder)))