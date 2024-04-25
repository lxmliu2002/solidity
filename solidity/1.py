import os
import re

def get_parameters(parameters):
    parameters = parameters.split(',')
    parameters = [parameter.strip() for parameter in parameters]
    result = {}
    # pattern = r"import\s+[\'\"](.+?)[\'\"]\;"
    # pattern_1 = r"\s*(address|string|bool)\s*"
    # pattern_2 = r"\s*(byte|uint)\s*"
    
    for parameter in parameters:
        parameter = parameter.split(' ')
        parameter_type = parameter[0]
        parameter_name = parameter[-1]
        if parameter_type not in result:
            result[parameter_type] = []
        result[parameter_type].append(parameter_name)
    return result


def extract_functions(filepath, extracted=None):
    def find_scopes(filename):
        with open(filename, 'r') as f:
            contract_content = f.read()
        
        scopes = {'interface': {}, 'contract': {}, 'library': {}, 'error': {}}
        current_scope = None
        current_name = None
        lines = contract_content.split('\n')
        stack = []
        for line in lines:
            print(line)
            # print(stack)
            interface_match = re.match(r'^\s*interface\s+(\w+)\s*{', line)
            interface_is_match = re.match(r'^\s*interface\s+(\w+)\s+(is).*{', line)
            contract_match = re.match(r'^(abstract)*\s*contract\s+(\w+)\s*{', line)
            contract_is_match = re.match(r'^(abstract)*\s*contract\s+(\w+)\s+(is).*{', line)
            library_match = re.match(r'^\s*library\s+(\w+)\s*{', line)
            error_match = re.match(r'^(error)\s+(\w+)\s*\((.*?)\)\s*', line)
            if error_match:
                # if '{' in line:
                #     stack.append('{')
                current_scope = 'error'
                current_name = error_match.group(2)
                scopes[current_scope][current_name] = {}
                parameters = error_match.group(3)
                parameters = get_parameters(parameters)
                scopes[current_scope][current_name] = parameters
                current_scope = None
                current_name = None
                continue

            if interface_is_match:
                # print(contract_is_match)
                if '{' in line:
                    stack.append('{')
                # print(stack)
                current_scope = 'contract'
                current_name = interface_is_match.group(1)
                # print(current_name)
                scopes[current_scope][current_name] = []
                continue
            if interface_match:
                stack.append('{')
                # print(stack)
                current_scope = 'interface'
                current_name = interface_match.group(1)
                scopes[current_scope][current_name] = []
                continue
            if contract_is_match:
                # print(contract_is_match)
                if '{' in line:
                    stack.append('{')
                # print(stack)
                current_scope = 'contract'
                current_name = contract_is_match.group(2)
                # print(current_name)
                scopes[current_scope][current_name] = []
                continue
            if contract_match:
                # print(contract_match)
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
    error_flag = False
    for contract_scope, items in events_functions.items():
        if contract_scope == 'error':
            if error_flag:
                continue
            extracted[filename]['error'] = events_functions['error']
            error_flag = True
            continue
        for contract_name, code in items.items():
            extracted[filename][contract_name] = {}
            stack = []
            # if contract_name == 'error':
            #     continue
            for index in range(len(code)):
                line = code[index]
                match = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(2)
                    parameters = match.group(3)
                    
                    parameters = get_parameters(parameters)
                    
                    extracted[filename][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(constructor|fallback|receive)\s*\((.*?)\)\s*', line)
                if match:
                    function_type = match.group(1)
                    if function_type not in extracted[filename][contract_name]:
                        extracted[filename][contract_name][function_type] = {}
                    function_name = match.group(1)
                    parameters = match.group(2)
                    parameters = get_parameters(parameters)
                    extracted[filename][contract_name][function_type][function_name] = parameters
                    continue
                match = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\(*', line)
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
                                parameters = re.match(r'^\s*(event|function|modifier|error)\s+(\w+)\s*\((.*?)\)\s*', parameters).group(3)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
                match = re.match(r'^\s*(constructor|fallback|receive)\s+(\w+)\s*\(*', line)
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
                                parameters = re.match(r'^\s*(constructor|fallback|receive)\s*\((.*?)\)\s*', parameters).group(2)
                                parameters = get_parameters(parameters)
                                extracted[filename][contract_name][function_type][function_name] = parameters
                                break
                        parameters += line.strip()
                        index += 1
    
    return extracted


extracted = {}

filepath = '/mnt/data/chenlongfei/liuxm/solidity/solidity/test/0x703ee3e326600e9fa113eea2c693eaebadc3ce27/1_29_Initializable.sol'

functions_events = extract_functions(filepath, extracted)

for filename, items in functions_events.items():
    print(f"{filename}:")
    for contract_name, functions in items.items():
        print(f"{contract_name}:")
        if contract_name == 'error':
            # print(functions)
            for error_names, parameters in functions.items():
                print(f"  {error_names}:")
                for parameters_type, parameters in parameters.items():
                    print(f"    {parameters_type}")
                    print(parameters)

            continue
        for function_type, functions in functions.items():
            print(f"  {function_type}:")
            for function_name, parameters in functions.items():
                print(f"    {function_name}")
                # print(parameters)
                for parameters_type, parameters_name in parameters.items():
                    print(f"      {parameters_type}: {parameters_name}")
                # parameters = get_parameters(parameters)
                # print(parameters)
            # print()