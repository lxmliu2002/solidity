# Sol文件批量处理工具

### Requirements

* Python >= 3.6

* re

* os

* json

* tqdm

* time

* timeout_decorator

* multiprocessing

* traceback

* functools

### 文件说明

1. ./solidity/re_delete.py 用于通过将编译输出json文件的abi源代码中的函数进行对比，删除没有用到的函数，在代码文件夹下生成一个前缀为delete_的sol文件。

2. ./solidity/re_complete.py 用于通过按照合约中的import关系，将多个合约文件合并到一起，其余不作任何处理，在代码文件夹下生成一个前缀为complete_的sol文件。

### 运行说明

1. 建议先运行re_delete.py，否则生成的complete文件会干扰delete脚本的运行。

2. 将合约压缩代码文件解压至./contracts/codes，将合约编译json文件解压至./contracts/jsons

3. 直接运行两个py文件，错误信息将输出在./error中

Compile 1000 Files
Total Time Cost: 2007.9720842838287
Average Time Cost: 2.007972084283829

生成的编译文件放在compile_info目录下，若编译失败，异常信息保存在error_info目录下。
