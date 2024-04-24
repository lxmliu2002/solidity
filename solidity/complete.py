import os
import re
import json
from tqdm import tqdm
import time
import timeout_decorator
import multiprocessing
import traceback
from functools import partial


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

def get_version(input_file, output_file, remaining_filepath, filter_f):
    pattern = r'pragma\s+solidity\s+(\^?>?=?\d+\.\d+\.\d+);'
    with open(input_file, 'r') as f:
        content = f.read()

    matches = re.finditer(pattern, content)
    with open(output_file, 'w') as matched_f, open(remaining_filepath, 'w') as remaining_f:
        last_end = 0
        for match in matches:
            start_index = match.start()
            end_index = match.end()
            matched_content = match.group(0)
            preceding_content = content[last_end:start_index]
            matched_f.write(preceding_content + matched_content + '\n')
            last_end = end_index
        remaining_content = content[last_end:]
        remaining_f.write(remaining_content)
    get_contents(remaining_filepath, filter_f)

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

def read_abis(abi_path):
    abis = {}
    
    with open(abi_path, 'r', encoding='utf-8') as f:
        data:dict[str, dict[str, dict]] = json.load(f)

    for filename, contracts in data['contracts'].items():
        if filename not in abis:
            abis[filename] = {}

        for contract, details in contracts.items():
            if contract not in abis[filename]:
                abis[filename][contract] = {}
                
            for abi_item in details['abi']:
                
                abi_type = abi_item.get('type', None)
                abi_name = abi_item.get('name', None)
                abi_inputs = abi_item.get('inputs', None)
                
                if abi_type not in abis[filename]:
                    abis[filename][contract][abi_type] = {}
                
                if abi_type == 'constructor':
                    abi_name = 'constructor'
                
                if abi_type == 'fallback':
                    abi_name = 'fallback'
                
                if abi_name:
                    abis[filename][contract][abi_type][abi_name] = {}
                
                if abi_inputs:
                    for input_item in abi_inputs:
                        input_type = input_item.get('type', None)
                        input_name = input_item.get('name', None)
                        
                        if input_type not in abis[filename][contract][abi_type][abi_name]:
                            abis[filename][contract][abi_type][abi_name][input_type] = []
                        
                        if input_name:
                            abis[filename][contract][abi_type][abi_name][input_type].append(input_name)
    
    return abis

def get_contents(input_file_path, output_file_path):
    pattern_pragma = r'pragma\s+solidity\s+(\^?>?=?\d+\.\d+\.\d+);'
    pattern_import = r"import\s+[\'\"](.+?)[\'\"]\;"
    
    with open(input_file_path, 'r') as f:
        data = f.read()
    data = re.sub(pattern_import, '', data)
    data = re.sub(pattern_pragma, '', data)
    data = delete_comments(data)
    data = "\n".join([i for i in data.split("\n") if i.strip() != ""])
    
    tmppath = os.path.join(os.path.dirname(input_file_path), "tmp.sol")
    with open(tmppath, 'w') as f:
        f.write(data)
    
    with open(output_file_path, 'a') as output_file:
        output_file.write(data)
        output_file.write('\n')
    os.remove(tmppath)

def get_json_path(jsons_list, file_path):
    address = os.path.basename(os.path.dirname(file_path))
    for json_file in jsons_list:
        if address == json_file.split('_')[0]:
            return json_file

def check_sol_files(directory):
    """Check for Solidity files in the given directory."""
    return [filename for filename in os.listdir(directory) if filename.endswith('.sol')]

@timeout_decorator.timeout(50, use_signals=True)
def file_import(path, importlists:list=None, G=None):
    if importlists is None:
        importlists = []
    if G is None:
        G = {}
    try:
        with open(path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        pattern = r"import\s+[\'\"](.+?)[\'\"]\;"
        pattern_from = r"import\s*{.*}\s*from\s*[\'\"](.+?)[\'\"]\;"
        file_name = os.path.basename(path)
        if file_name not in G:
            G[file_name] = []
        for line in lines:
            if re.match(pattern, line):
                match = re.match(pattern, line)
                matchpath = os.path.join(os.path.dirname(path), match.group(1)[2:])
                if os.path.exists(matchpath):
                    file_import(matchpath, importlists, G)
                    importlists.append(matchpath)
                # importlists.append(matchpath)
                if match not in G[file_name]:
                    G[file_name].append(match)
                continue
            if re.match(pattern_from, line):
                match = re.match(pattern_from, line)
                matchpath = os.path.join(os.path.dirname(path), match.group(1)[2:])
                # importlists.append(matchpath)
                if os.path.exists(matchpath):
                    file_import(matchpath, importlists, G)
                    importlists.append(matchpath)
                if match not in G[file_name]:
                    G[file_name].append(match)
                continue
            


        # matches = re.findall(pattern, content)
        # file_name = os.path.basename(path)
        # if file_name not in G:
        #     G[file_name] = []
        # for match in matches:
        #     if match not in G[file_name]:
        #         G[file_name].append(match)
        #     matchpath = os.path.join(os.path.dirname(path), match[2:])
        #     if os.path.exists(matchpath):
        #         file_import(matchpath, importlists, G)
        #         importlists.append(matchpath)

    except Exception as e:
        pass
    return G, importlists

def process_directory(source_code_folder):
    """Process each directory in the root directory."""

    for p in tqdm(os.listdir(source_code_folder)):
        path = os.path.join(source_code_folder, p)
        try:
            if not check_sol_files(path):
                raise FileNotFoundError("Error: No contracts found.")
            filename = get_filename(path)
            output_filename = "complete_" + filename
            remaining_filename = "remaining.sol"
            filter_filename = "filter.sol"
            filepath = os.path.join(path, filename)
            
            out_filepath = os.path.join(path, output_filename)
            remaining_filepath = os.path.join(path, remaining_filename)
            filter_filepath = os.path.join(path, filter_filename)
            get_version(filepath, out_filepath, remaining_filepath, filter_filepath)
            G, importlists = file_import(filepath)

            seen = set()
            for item in importlists:
                if item not in seen:
                    seen.add(item)
                    get_contents(item, out_filepath)

            get_contents(filepath, out_filepath)
            
            os.remove(remaining_filepath)
            os.remove(filter_filepath)

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
        output_filename = filename + "_integration.sol"
        remaining_filename = "remaining.sol"
        filter_filename = "filter.sol"
        filepath = os.path.join(path, filename)
        
        out_filepath = os.path.join(path, output_filename)
        remaining_filepath = os.path.join(path, remaining_filename)
        filter_filepath = os.path.join(path, filter_filename)
        get_version(filepath, out_filepath, remaining_filepath, filter_filepath)
        G, importlists = file_import(filepath)
        jsonpath = get_json_path(json_list, filepath)
        abis = read_abis(jsonpath)
        
        seen = set()
        for item in importlists:
            if item not in seen:
                seen.add(item)
                get_contents(item, out_filepath, G, abis)

        get_contents(filepath, out_filepath, G, abis)
        
        os.remove(remaining_filepath)
        os.remove(filter_filepath)

    except FileNotFoundError as e:
        handle_error(e, p)
    except Exception as e:
        handle_error(e, p)

def handle_error(e, p, filename=None):
    """Handle errors and write traceback to a file."""
    with open(os.path.join("/home/lxm/solidity/solidity/error", p + ".log"), "w") as file:
        file.write(traceback.format_exc())

if __name__ == "__main__":
    st = time.time()
    source_code_folder = "/home/lxm/solidity/solidity/new/codes"
    # json_folder = "/home/lxm/solidity/solidity/new/jsons"
    num_processes = 56
    
    # source_code_list = [subfolder for subfolder in os.listdir(source_code_folder) if os.path.isdir(os.path.join(source_code_folder, subfolder))]
    # json_list = [file for file in os.listdir(json_folder) if os.path.isfile(os.path.join(json_folder, file))]
    
    
    # with multiprocessing.Pool(processes=num_processes) as pool:
    #     process_func = partial(multi_process_directory, source_code_folder)
    #     list(tqdm(pool.imap(process_func, [p for p in os.listdir(source_code_folder)]), total = len(os.listdir(source_code_folder))))
    #     pool.close()
    #     pool.join()
    
    process_directory(source_code_folder)

    ed = time.time()
    print("Total Time Cost:",ed - st)
    print("Average Time Cost:", (ed - st) / len(os.listdir(source_code_folder)))