import pandas as pd
import csv
import os
import shutil

# 获取文件列表
file_count = 50
for x in range(1, file_count + 1):
    input_filename = f'raw_part_{x}.csv'
    output_filename = f'medium_part_{x}.csv'

    # 读入原始数据
    raw = pd.read_csv(input_filename, delimiter='\t', header=None)
    raw = raw.values.tolist()

    # 进行格式调整
    with open(output_filename, "w+", newline='') as csvFile:
        writer = csv.writer(csvFile)
        for i in range(len(raw)):
            writer.writerow(raw[i])

# 获取所有 medium_part_x.csv 文件的列表并排序
file_list = [f for f in os.listdir('.') if f.startswith('medium_part_') and f.endswith('.csv')]
file_list.sort(key=lambda x: int(x.split('_')[-1].split('.')[0]))  # 根据 x 进行排序

# 打开最终输出文件
with open('final.csv', 'w', newline='') as final_file:
    writer = csv.writer(final_file)
    
    for input_file in file_list:
        with open(input_file, 'r') as infile:
            reader = csv.reader(infile)
            for row in reader:
                writer.writerow(row)

# 获取所有 medium_part_x.csv 文件的列表
file_list = [f for f in os.listdir('.') if f.startswith('medium_part_') and f.endswith('.csv')]

# 删除文件
for file in file_list:
    os.remove(file)

# 源文件夹和目标文件夹
source_folder = "./"  # 当前目录
target_folder = "./data"

# 创建目标文件夹（如果不存在）
if not os.path.exists(target_folder):
    os.makedirs(target_folder)

# 获取所有符合命名逻辑的文件
file_prefix = "raw_part_"
file_suffix = ".csv"

for filename in os.listdir(source_folder):
    # 检查文件是否符合命名逻辑
    if filename.startswith(file_prefix) and filename.endswith(file_suffix):
        source_path = os.path.join(source_folder, filename)
        target_path = os.path.join(target_folder, filename)
        
        # 移动文件
        shutil.move(source_path, target_path)
        
print("All transaction complete")
