clear;
close all;
clc;

% 雷达串口设置
serialPort_string = 'COM3';
baudrate = 230400;
comPort = serialport(serialPort_string, baudrate, 'Timeout', 1);
serialPort = comPort;
configureTerminator(serialPort, 'CR/LF');
flush(serialPort);
pause(0.1);

% 电机串口设置
motorPort_string = 'COM1';
motorate = 19200;
conPort = serialport(motorPort_string, motorate, 'Timeout', 1);
motorPort = conPort;
configureTerminator(motorPort, 'CR');
flush(motorPort);
pause(0.1);

% 确定成像物体的行数和列数，暂定100mm*100mm
Columns = 100;
Rows = 100;
pixel = Columns * Rows;

% 写雷达设置标志字
SYS_CONFIG = '!S00032012'; 
RFE_CONFIG = '!F00075300'; 
PLL_CONFIG = '!P00000BB8'; 
BBS_CONFIG = '!BE422E674'; 
WriteBuffer(SYS_CONFIG, RFE_CONFIG, PLL_CONFIG, BBS_CONFIG, serialPort); 

% 数据存储逻辑
dataBuffer = {};            % 用于存储当前批次的数据
fileCount = 1;              % 文件计数器
frameCount = 0;             % 数据帧计数器
maxFramesPerFile = Rows;    % 每个文件存储的最大数据帧数

% 将电机归零
WriteMotor('HX\n\r', motorPort);
WriteMotor('HY\n\r', motorPort);

% 数据采集
for item = 1:pixel
    while true
        % 从串口读取数据
        str = readline(serialPort);
        % 读取到 M 帧，电机 X 轴移动
        if strfind(str, "M") == 2
            WriteMotor('+X,400\n\r', motorPort);
            break;
        end
    end
    
    % 将当前数据帧添加到缓冲区
    frameCount = frameCount + 1;
    dataBuffer{end+1} = str; %#ok<*SAGROW>
    
    % 检查是否达到最大帧数，保存并重置缓冲区
    if frameCount >= maxFramesPerFile
        % 生成文件名
        filename = sprintf('raw_part_%d.csv', fileCount);
        % 打开新文件并写入数据
        fid = fopen(filename, 'w+');
        for i = 1:numel(dataBuffer)
            fprintf(fid, "%s\n", dataBuffer{i});
        end
        fclose(fid);
        
        % 输出保存提示
        fprintf('Saved %d frames to %s\n', frameCount, filename);
        
        % 重置计数器和缓冲区，电机 Y 轴移动，X 轴归零
        frameCount = 0;
        dataBuffer = {};
        fileCount = fileCount + 1;
        WriteMotor('+Y,400\n\r', motorPort);
        WriteMotor('HX\n\r', motorPort);

        % 当 X 轴归零后才继续数据采集
        while true
            motorInfo = readline(motorPort);
            if strfind(motorInfo, "0") == 4
                break;
            end
        end
    end
end

% 设置 Python 脚本路径
scriptPath = 'process.py';

% 设置 Python 解释器路径
pythonPath = 'D:\Anaconda\envs\radar\python.exe';

% 构造命令并执行
cmd = sprintf('"%s" "%s"', pythonPath, scriptPath);
[status, result] = system(cmd);

% 检查结果
if status == 0
    disp('Python script executed successfully:');
    disp(result);
else
    disp('Error executing Python script:');
    disp(result);
end

% 读取 CSV 文件，取出需要的数据
data = readmatrix('final.csv'); 
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

