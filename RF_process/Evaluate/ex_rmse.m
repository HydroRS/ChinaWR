clc; clear;

% 读取 Excel 文件中的数据
data = xlsread('D:\画图\水资源月分配.xlsx');

% 提取两列数据
col1 = data(:, 3); % 第一列数据
col2 = data(:, 2); % 第二列数据

% 去掉包含 NaN 的行
validRows = ~isnan(col1) & ~isnan(col2);
col1 = col1(validRows);
col2 = col2(validRows);

% 计算 RMSE
rmse = sqrt(mean((col1 - col2).^2));

% 显示 RMSE
disp(['RMSE: ', num2str(rmse)]);
