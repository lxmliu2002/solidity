import json
import os
import re


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

def file_import(path, importlists:list=None, G=None):
    if importlists is None:
        importlists = []
    if G is None:
        G = {}
    try:
        with open(path, 'r', encoding='utf-8') as file:
            content = file.read()
        pattern = r"import\s+[\'\"](.+?)[\'\"]\;"
        matches = re.findall(pattern, content)
        file_name = os.path.basename(path)
        if file_name not in G:
            G[file_name] = []
        for match in matches:
            if match not in G[file_name]:
                G[file_name].append(match)
            matchpath = os.path.join(os.path.dirname(path), match[2:])
            if os.path.exists(matchpath):
                file_import(matchpath, importlists, G)
                importlists.append(matchpath)

    except Exception as e:
        pass
    return G, importlists

def get_parameters(parameters):
    parameters = parameters.split(',')
    parameters = [parameter.strip() for parameter in parameters]
    result = {}
    for parameter in parameters:
        parameter = parameter.split(' ')
        parameter_type = parameter[0]
        parameter_name = parameter[-1]
        result[parameter_type] = parameter_name
    return result

def extract_functions(filepath, extracted=None):
    def find_scopes(filename):
        with open(filename, 'r') as f:
            contract_content = f.read()
        
        scopes = {'interface': {}, 'contract': {}, 'library': {}}
        current_scope = None
        current_name = None
        lines = contract_content.split('\n')
        stack = []
        for line in lines:
            # print(line)
            # print(stack)
            interface_match = re.match(r'^\s*interface\s+(\w+)\s*{', line)
            contract_match = re.match(r'^(abstract)*\s*contract\s+(\w+)\s*{', line)
            library_match = re.match(r'^\s*library\s+(\w+)\s*{', line)
            if interface_match:
                stack.append('{')
                # print(stack)
                current_scope = 'interface'
                current_name = interface_match.group(1)
                scopes[current_scope][current_name] = []
                continue
            if contract_match:
                stack.append('{')
                # print(stack)
                current_scope = 'contract'
                current_name = contract_match.group(2)
                scopes[current_scope][current_name] = []
                continue
                
            if library_match:
                stack.append('{')
                # print(stack)
                current_scope = 'library'
                current_name = library_match.group(1)
                scopes[current_scope][current_name] = []
                continue
            
            if '{' in line:
            # if re.match(r'*{*', line):
                stack.append('{')
                # print(stack)
                scopes[current_scope][current_name].append(line)
                continue
                
            if re.match(r'^\s*}\s*$', line):
                stack.pop()
                # print(stack)
                if len(stack) == 0:
                    current_scope = None
                    current_name = None
                else:
                    scopes[current_scope][current_name].append(line)
                continue
                
            if current_scope and current_name:
                scopes[current_scope][current_name].append(line)
        return scopes
    events_functions = find_scopes(filepath)
    filename = os.path.basename(filepath)
    extracted[filename] = {}
    for _, items in events_functions.items():
        for contract_name, code in items.items():
            extracted[filename][contract_name] = {}
            stack = []
            for index in range(len(code)):
                line = code[index]
                match = re.match(r'^\s*(event|function|error|modifier)\s+(\w+)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = match.group(3)
                    
                    parameters = get_parameters(parameters)
                    
                    extracted[filename][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(constructor|fallback)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(1)
                    parameters = match.group(2)
                    parameters = get_parameters(parameters)
                    extracted[filename][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(event|function|error|modifier)\s+(\w+)\s*\(*', line)
                if match:
                    stack.append('(')
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = line
                    index += 1
                    while index < len(code):
                        line = code[index]
                        if ')' in line:
                            stack.pop()
                            parameters += line.strip()
                            
                            if len(stack) == 0:
                                parameters = re.match(r'^\s*(event|function|error|modifier)\s+(\w+)\s*\((.*?)\)\s*', parameters).group(3)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
                match = re.match(r'^\s*(constructor|fallback)\s+(\w+)\s*\(*', line)
                if match:
                    stack.append('(')
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = line
                    index += 1
                    while index < len(code):
                        line = code[index]
                        if ')' in line:
                            stack.pop()
                            parameters += line.strip()
                            
                            if len(stack) == 0:
                                parameters = re.match(r'^\s*(constructor|fallback)\s*\((.*?)\)\s*', parameters).group(2)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
    return extracted





filename = "integration_GnosisSafeProxy.sol"
filepath = "/home/lxm/solidity/solidity/new/codes/0x3cE9Bb52894E2d4Bc3B659B4F7a35f7556cB9FdD_GnosisSafeProxy/integration_GnosisSafeProxy.sol"

abis = read_abis("/home/lxm/solidity/solidity/testfiles/0x96faffc7384f90806573d57f8bd45aa2911e9220_GnosisSafeProxy_type5.json")

G, importlists = file_import(filepath)

extracted = {}

functions_events = extract_functions(filepath, extracted)

