clc; clear;
novalue = -1.797693000000000e+308;
folder1 = 'D:\地下水产品\';
fileList1 = dir(fullfile(folder1, '*.tif')); % tif 文件列表

%% 1、 找对应经纬度数据
given_lon = 118.93; % 经度
given_lat = 42.87; % 纬度37.40	104.90

% 初始化结果数组，长度为 21，对应 2000 到 2020 年
value = zeros(1, 21);

file_name = fileList1(file_index1).name;

info = geotiffinfo(fullfile(folder1, file_name));
[data_tiff, R] = readgeoraster(fullfile(folder1, file_name)); % 读取地理栅格数据
data_ly = double(data_tiff); % 将数据转换为 double 类型的矩阵

% 展平矩阵以便处理
Water = data_ly(:);

% 找到非零值
waters = find(Water ~= novalue);
grw = Water(waters);

% 找到非零值的行和列索引
[row, col] = find(data_tiff ~= novalue);

% 获得投影系统的坐标（pix2map）
[lon_ly, lat_ly] = pix2map(info.RefMatrix, row, col);

% 使用 knnsearch 寻找最近的经纬度点
[nearest_index, nearest_distance] = knnsearch([lon_ly, lat_ly], [given_lon, given_lat], 'k', 1, 'Distance', 'euclidean');

% 获取最邻近的经纬度和对应的值
nearest_value = grw(nearest_index);


% 显示结果
disp(value);
