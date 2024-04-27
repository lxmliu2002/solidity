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

def read_abis(abi_path):
    abis = {}
    
    with open(abi_path, 'r', encoding='utf-8') as f:
        data:dict[str, dict[str, dict]] = json.load(f)

    for filename, contracts in data['contracts'].items():
        if filename not in abis:
            abis[filename] = {}

        for contract_name, details in contracts.items():
            if contract_name not in abis[filename]:
                abis[filename][contract_name] = {}
                
            for abi_item in details['abi']:
                
                abi_type = abi_item.get('type', None)
                
                abi_name = abi_item.get('name', None)
                
                abi_inputs = abi_item.get('inputs', None)
                
                if abi_type not in abis[filename][contract_name]:
                    abis[filename][contract_name][abi_type] = {}
                
                
                if abi_type == 'constructor':
                    abi_name = 'constructor'
                
                if abi_type == 'fallback':
                    abi_name = 'fallback'
                
                if abi_name:
                    abis[filename][contract_name][abi_type][abi_name] = {}
                if abi_inputs:
                    for input_item in abi_inputs:
                        input_type = input_item.get('internalType', None)
                        if input_type and "contract" in input_type:
                            input_type = input_type.replace("contract ", "")
                        if not input_type:
                            input_type = input_item.get('type', None)
                        input_name = input_item.get('name', None)
                        
                        if input_type not in abis[filename][contract_name][abi_type][abi_name]:

                            abis[filename][contract_name][abi_type][abi_name][input_type] = []
                        
                        if input_name:
                            abis[filename][contract_name][abi_type][abi_name][input_type].append(input_name)
    
    return abis


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
@limit_recursion_depth(10)
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

   
def get_parameters(parameters):
    parameters = parameters.split(',')
    parameters = [parameter.strip() for parameter in parameters]
    result = {}
    
    for parameter in parameters:
        parameter = parameter.split(' ')
        parameter_type = parameter[0]
        if parameter_type == 'uint':
            parameter_type = 'uint256'
        parameter_name = parameter[-1]
        if parameter_type not in result:
            result[parameter_type] = []
        result[parameter_type].append(parameter_name)
    return result

def extract_functions(filename, function_details, extracted={}):
    def find_scopes(contract_content):
        
        scopes = {'interface': {}, 'contract': {}, 'library': {}, 'error': {}}
        current_type = None
        current_name = None
        lines = contract_content.split('\n')
        stack = []
        for line in lines:
            interface_match = re.match(r'^\s*interface\s+(\w+)\s*{', line)
            interface_is_match = re.match(r'^\s*interface\s+(\w+)\s+(is).*{', line)
            contract_match = re.match(r'^(abstract)*\s*contract\s+(\w+)\s*{', line)
            contract_is_match = re.match(r'^(abstract)*\s*contract\s+(\w+)\s+(is).*{', line)
            library_match = re.match(r'^\s*library\s+(\w+)\s*{', line)
            error_match = re.match(r'^(error)\s+(\w+)\s*\((.*?)\)\s*', line)
            if error_match:
                current_type = 'error'
                current_name = error_match.group(2)
                scopes[current_type][current_name] = {}
                parameters = error_match.group(3)
                parameters = get_parameters(parameters)
                scopes[current_type][current_name] = parameters
                current_type = None
                current_name = None
                continue

            if interface_is_match:
                if '{' in line:
                    stack.append('{')
                current_type = 'contract'
                current_name = interface_is_match.group(1)
                scopes[current_type][current_name] = []
                continue
            if interface_match:
                stack.append('{')
                current_type = 'interface'
                current_name = interface_match.group(1)
                scopes[current_type][current_name] = []
                continue
            if contract_is_match:
                if '{' in line:
                    stack.append('{')
                current_type = 'contract'
                current_name = contract_is_match.group(2)
                scopes[current_type][current_name] = []
                continue
            if contract_match:
                stack.append('{')
                current_type = 'contract'
                current_name = contract_match.group(2)
                scopes[current_type][current_name] = []
                continue
            if library_match:
                stack.append('{')
                current_type = 'library'
                current_name = library_match.group(1)
                scopes[current_type][current_name] = []
                continue
            
            if '{' in line:
                stack.append('{')
                scopes[current_type][current_name].append(line)
                continue
                
            if re.match(r'^\s*}\s*$', line):
                stack.pop()
                if len(stack) == 0:
                    current_type = None
                    current_name = None
                else:
                    scopes[current_type][current_name].append(line)
                continue
                
            if current_type and current_name:
                scopes[current_type][current_name].append(line)
        return scopes
    events_functions = find_scopes(function_details)
    extracted[filename] = {'interface': {}, 'contract': {}, 'library': {}, 'error': {}}

    error_flag = False
    for contract_type, items in events_functions.items():
        if contract_type == 'error':
            if error_flag:
                continue
            extracted[filename]['error'] = events_functions['error']
            error_flag = True
            continue
        for contract_name, code in items.items():
            extracted[filename][contract_type][contract_name] = {}
            stack = []

            for index in range(len(code)):
                line = code[index]
                match = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_type][contract_name]:
                        extracted[filename][contract_type][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = match.group(3)
                    
                    parameters = get_parameters(parameters)
                    
                    extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(constructor|fallback|receive)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_type][contract_name]:
                        extracted[filename][contract_type][contract_name][function_type] = {}
                    function_name = match.group(1)
                    parameters = match.group(2)
                    parameters = get_parameters(parameters)
                    extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\(+', line)
                if match:
                    stack.append('(')
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_type][contract_name]:
                        extracted[filename][contract_type][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = line
                    index += 1
                    while index < len(code):
                        line = code[index]
                        if ')' in line:
                            stack.pop()
                            parameters += line.strip()
                            if len(stack) == 0:
                                parameters = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\((.*?)\)\s*', parameters).group(3)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
                    continue
                match = re.match(r'^\s*(modifier)\s+(\w+)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_type][contract_name]:
                        extracted[filename][contract_type][contract_name][function_type] = {}
                    function_name = match.group(2)
                    extracted[filename][contract_type][contract_name][function_type][function_name] = {}
                        
                    if '(' in line:
                        stack.append('(')
                        parameters = line
                        index += 1
                        while index < len(code):
                            line = code[index]
                            if ')' in line:
                                stack.pop()
                                parameters += line.strip()
                                if len(stack) == 0:
                                    parameters = re.match(r'^\s*(modifier)\s+(\w+)\s*\((.*?)\)\s*', parameters).group(3)
                                    parameters = get_parameters(parameters)
                                    extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                                    break
                            parameters += line.strip()
                            index += 1
                    else:
                        index += 1
                        while index < len(code) and not ';' in code[index]:
                            if '(' in line:
                                stack.append('(')
                                parameters = line
                                index += 1
                                while index < len(code):
                                    line = code[index]
                                    if ')' in line:
                                        stack.pop()
                                        parameters += line.strip()
                                        if len(stack) == 0:
                                            parameters = re.match(r'^\s*(modifier)\s+(\w+)\s*\((.*?)\)\s*', parameters).group(3)
                                            parameters = get_parameters(parameters)
                                            extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                                            break
                                    parameters += line.strip()
                                    index += 1
                                break
                            index += 1
                        extracted[filename][contract_type][contract_name][function_type][function_name] = {'': ['']}
                    continue
                match = re.match(r'^\s*(constructor|fallback|receive)\s+(\w+)\s*\(+', line)
                if match:
                    stack.append('(')
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_type][contract_name]:
                        extracted[filename][contract_type][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = line
                    index += 1
                    while index < len(code):
                        line = code[index]
                        if ')' in line:
                            stack.pop()
                            parameters += line.strip()
                            
                            if len(stack) == 0:
                                parameters = re.match(r'^\s*(constructor|fallback|receive)\s*\((.*?)\)\s*', parameters).group(2)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_type][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
                    continue
                
    
    return extracted

def remove_function_block(input_string, aim_string):
    start = 0
    function_index = []
    while True:
        tmp_index = input_string.find(aim_string, start)
        if tmp_index == -1:
            break
        function_index.append(tmp_index)
        start = tmp_index + 1
        
    if len(function_index) > 1 or len(function_index) == 0:
        return input_string
    if function_index == -1:
        return input_string
    
    stack = []
    end_index = None
    for i in range(function_index[0], len(input_string)):
        if input_string[i] == '{':
            stack.append('{')
        elif input_string[i] == '}':
            if stack:
                stack.pop()
                if not stack:
                    end_index = i
                break
        elif input_string[i] == ';' and not stack:
            end_index = i
            break

    if end_index is not None:
        output_string = input_string[:function_index[0]] + input_string[end_index+1:]
    else:
        output_string = input_string
    
    return output_string

def get_final(delete_dict, abis, functions_events):

    final_dict = delete_dict
    for filename, items in functions_events.items():
        tmp = final_dict[filename]
        for contract_type, contracts in items.items():
            for contract_name, functions in contracts.items():
                if contract_name not in abis[filename]:
                    select_str = contract_type + " " + contract_name
                    tmp = remove_function_block(tmp, select_str)
                for function_type, function_details in functions.items():
                    for function_name, parameters in function_details.items():
                        if function_name == 'constructor' or function_name == 'fallback' or function_name == 'receive':
                            
                            if function_name not in abis[filename][contract_name]:
                                select_str = function_type
                                tmp = remove_function_block(tmp, select_str)
                                continue
                            # if '' not in parameters:
                            #     # print(parameters)
                            #     for parameters_type, parameters_name in parameters.items():
                            #         for parameter_name in parameters_name:
                            #             if parameter_name not in abis[filename][contract_name][function_name][function_name][parameters_type]:
                            #                 select_str = function_type
                            #                 tmp = remove_function_block(tmp, select_str)
                            #                 continue
                            #         continue
                            #     continue
                        if function_type not in abis[filename][contract_name]:
                            select_str = function_type + " " + function_name
                            tmp = remove_function_block(tmp, select_str)
                            continue
                        if function_name not in abis[filename][contract_name][function_type]:
                            select_str = function_type + " " + function_name
                            tmp = remove_function_block(tmp, select_str)
                            continue
                        # if '' not in parameters:
                        #     for parameters_type, parameters_name in parameters.items():
                        #         for parameter_name in parameters_name:
                        #             if parameter_name not in abis[filename][contract_name][function_type][function_name][parameters_type]:
                        #                 select_str = function_type + " " + function_name
                        #                 tmp = remove_function_block(tmp, select_str)
                        #                 continue
        final_dict[filename] = tmp
    return final_dict

def get_json_path(jsons_list, file_path):
    address = os.path.basename(os.path.dirname(file_path))
    for json_file in jsons_list:
        if address.split('_')[0] == json_file.split('_')[0]:
            return json_file

def process_directory(source_code_folder, jsons_folder, json_list):
    for p in tqdm(os.listdir(source_code_folder)):
        path = os.path.join(source_code_folder, p)
        try:
            if not check_sol_files(path):
                raise FileNotFoundError("Error: No contracts found.")
            filename = get_filename(path)
            output_filename = "delete_" + filename
            filepath = os.path.join(path, filename)
            out_filepath = os.path.join(path, output_filename)
            
            get_version(filepath, out_filepath)
            
            G, original_dict, delete_dict = file_import(filepath)
            
            try:
            
                json_path = os.path.join(jsons_folder, get_json_path(json_list, filepath))
                abis = read_abis(json_path)
                
                extracted = {}
                functions_events = {}
                for filename, items in delete_dict.items():
                    functions_events = extract_functions(filename, delete_dict[filename], extracted)
                    extracted = {}
                
                final_dict = get_final(delete_dict, abis, functions_events)
                
                with open(out_filepath, 'a') as f:
                    for file_name, contents in final_dict.items():
                        f.write(contents)
            except FileNotFoundError as e:
                handle_error(e, p)
            
        except FileNotFoundError as e:
            handle_error(e, p)
        except Exception as e:
            handle_error(e, p)

def multi_process_directory(source_code_folder, jsons_folder, json_list, p):
    path = os.path.join(source_code_folder, p)
    try:
        if not check_sol_files(path):
            raise FileNotFoundError("Error: No contracts found.")
        filename = get_filename(path)
        output_filename = "delete_" + filename
        filepath = os.path.join(path, filename)
        out_filepath = os.path.join(path, output_filename)
        
        get_version(filepath, out_filepath)
        
        G, original_dict, delete_dict = file_import(filepath)
        
        try:
        
            json_path = os.path.join(jsons_folder, get_json_path(json_list, filepath))
            abis = read_abis(json_path)
            
            extracted = {}
            functions_events = {}
            for filename, items in delete_dict.items():
                functions_events = extract_functions(filename, delete_dict[filename], extracted)
                extracted = {}
            
            final_dict = get_final(delete_dict, abis, functions_events)
            
            with open(out_filepath, 'a') as f:
                for file_name, contents in final_dict.items():
                    f.write(contents)
        except FileNotFoundError as e:
            handle_error(e, p)
        
    except FileNotFoundError as e:
        handle_error(e, p)
    except Exception as e:
        handle_error(e, p)

if __name__ == "__main__":
    st = time.time()
    
    source_code_folder = '/mnt/data/chenlongfei/liuxm/solidity/solidity/contracts/codes'
    jsons_folder = '/mnt/data/chenlongfei/liuxm/solidity/solidity/contracts/jsons'
    
    json_list = [file for file in os.listdir(jsons_folder) if os.path.isfile(os.path.join(jsons_folder, file))]
    
    num_processes = 56
    
    # process_directory(source_code_folder, jsons_folder, json_list)
    
    with multiprocessing.Pool(processes=num_processes) as pool:
        process_func = partial(multi_process_directory, source_code_folder, jsons_folder, json_list)
        list(tqdm(pool.imap(process_func, [p for p in os.listdir(source_code_folder)]), total = len(os.listdir(source_code_folder))))
        pool.close()
        pool.join()

    ed = time.time()
    print("Total Time Cost:",ed - st)
    print("Average Time Cost:", (ed - st) / len(os.listdir(source_code_folder)))