# Sol文件批量编译工具
### Requirements
* Python >= 3.6
* solcx (pip install py-solc-x)
### 执行过程
1. 运行solcx_all_version_install.py，预先安装所有的solidity编译器版本
2. 将合约压缩文件解压至./contracts
3. 直接运行./compile.sh完成4-6的步骤
4. 更改handleIndividualJson.py中数据目录的绝对路径，运行handleIndividualJson.py以从包含合约的json文件中抽取并生成合约对应的sol文件和metadata.json文件。
5. 更改pathUpdate.py中数据目录的绝对路径，运行pathUpdate.py以更改sol文件中所有import依赖路径并生成metadata.json文件
6. 更改batchCompile.py中数据及输出目录的绝对路径，运行batchCompile.py进行批量编译

Compile 1000 Files
Total Time Cost: 2007.9720842838287
Average Time Cost: 2.007972084283829

生成的编译文件放在compile_info目录下，若编译失败，异常信息保存在error_info目录下。
