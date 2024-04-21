import os
import re
    
    
def ReadLibraryName():
    LibraryPath = "../openzeppelin-contracts-master/contracts"
    L = []
    for dirpath, dirnames, filenames in os.walk(LibraryPath):
        for file in filenames:
            if os.path.splitext(file)[1] == '.sol':
                L.append(os.path.join(os.path.splitext(file)[0]))
    return L



LibratyName = ReadLibraryName()# 读取公开库名称
try:
    with open(f"{DataDir}/{ContractAddress}/code.sol", 'r') as f:
        src = f.readlines()
except Exception as e:
    # print(f"error during read file!{str(e)}, at {ContractAddress}")
    continue
if len(src[0]) > 100:
    continue
# print(ContractAddress)
# print(src[0])
openSource = []
for line in src:
    matchLib = re.search(r"^library\s+(\w+)\s*", line)# 定义为 library 类型的库
    if matchLib:
        T = matchLib.group(1)
        if T in LibratyName:
            openSource.append(T)
            # print(f"{T},{ContractAddress}")
    matchContract = re.search(r"^contract\s+(\w+)\s*", line)# 定义为 contract 类型的库
    if matchContract:
        T = matchContract.group(1)
        if T in LibratyName:
            openSource.append(T)
            # print(f"{T},{ContractAddress}")
    matchInterface = re.search(r"^interface\s+(\w+)\s*", line)# 定义为 interface 类型的库
    if matchInterface:
        T = matchInterface.group(1)
        if T in LibratyName:
            openSource.append(T)
            # print(f"{T},{ContractAddress}")