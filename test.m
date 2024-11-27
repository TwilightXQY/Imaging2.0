clear;
close all;
clc;

% 读取 CSV 文件，取出需要的数据
data = readmatrix('final_metal.csv'); 
data(:, 1:3) = [];

% 确定块大小和目标数组尺寸
block_size = 50;
[num_rows, num_cols] = size(data);

% 将数据分块成三维数组
num_blocks = num_rows / block_size; % 块的数量
result = zeros(block_size, block_size, num_cols); % 初始化三维数组

for i = 1:num_cols
    % 将第i列的每50行重新排列成50*50的二维块，并放入三维数组中
    temp = reshape(data(:, i), block_size, num_blocks);
    result(:, :, i) = temp;
end
