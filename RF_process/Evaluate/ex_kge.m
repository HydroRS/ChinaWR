clc; clear;

% 读取 Excel 文件中的数据
data = xlsread('D:\画图\产品比较\地下水\地下水对比.xlsx');

% 提取两列数据
col1 = data(:,1) % 第一列数据为观测数据
col2 = data(:,2); % 第二列数据为模拟数据

% 去掉包含 NaN 的行
validRows = ~isnan(col1) & ~isnan(col2);
col1 = col1(validRows);
col2 = col2(validRows);

% 计算观测数据和模拟数据的均值
mean_obs = mean(col1');
mean_sim = mean(col2');

% 计算标准差
std_obs = std(col1');
std_sim = std(col2');

% 计算相关系数
r = corr(col1', col2');

% 计算KGE
alpha = std_sim / std_obs;
beta = mean_sim / mean_obs;
KGE = 1 - sqrt((r-1)^2 + (alpha-1)^2 + (beta-1)^2);

% 显示 KGE
disp(['KGE: ', num2str(KGE)]);
