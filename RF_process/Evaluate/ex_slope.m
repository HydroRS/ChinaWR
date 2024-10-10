clc; clear;

% 读取 Excel 文件中的数据
data = xlsread('C:\Users\HP\Desktop\整理十大流域数据.xlsx');

% 提取第一行数据
first_row = data(1, :);

% 生成对应的 X 值 (假设 X 是从 1 到列数)
x = 1:length(first_row);

% 去掉包含 NaN 的列
validCols = ~isnan(first_row);
x = x(validCols);
y = first_row(validCols);

% 使用 polyfit 计算斜率和截距
p = polyfit(x, y, 1);

% 提取斜率
slope = p(1);

% 显示斜率
disp(['Slope: ', num2str(slope)]);
