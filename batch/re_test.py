import re
def version_test():
    version = ">=0.5.1"
    version_map = {
            "^0.4": "0.4.26",
            "^0.5": "0.5.17",
            "^0.6": "0.6.12",
            "^0.7": "0.7.6",
            "^0.8": "0.8.24",
        }
    if version.startswith("=") or version.startswith("^"):
        version = version[1:]
        return version
    if version.startswith(">="):
        version = version[2:]
        return version_map.get('^' + version[:3], version)
    if version.startswith(">"):
        version = version[1:]
        return version_map.get('^' + version[:3], version)
    
    return version
result = version_test()
exit()

filename = '01_02_abc.sol'
content = 'import \"abc.sol\"; import \"./abc.sol\"; import \"../contract/abc/abc.sol\"; import \"aabc.sol\"'
print(content)
if filename.endswith('.sol'):
    replacement = f'"{r"./"+filename}"'
    pattern = rf'([\'"])({re.escape("_".join(filename.split("_")[2:]))}\1)'
    content = re.sub(pattern, replacement, content)
    print(content)
    pattern = rf'([\'"])((?:(?!\1).)*{"/" + re.escape("_".join(filename.split("_")[2:]))}\1)'
    content = re.sub(pattern, replacement, content)
    
    # pattern = rf'([\'"])((?:(?!\1).)*([\'"/]){re.escape("_".join(filename.split("_")[2:]))}\1)'
    # pattern = rf'[\'"]((?:(?!\1).)*abc\.sol'
    
    
print(content)