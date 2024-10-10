clc; clear;

% 定义文件夹路径
outputFolder = 'F:\';

% 获取DEM的地理信息
DemPath = 'D:\DEM.tif';
info = geotiffinfo(DemPath);
DEM = imread(DemPath);

% 定义年份
years = 1980:2020;
data_Liuyu_runoff = [];

% 遍历每个.nc文件
for ii = 1:41
    year=years(ii);
    datapath = fullfile('F:\', num2str(year));
    fileList1 = dir(fullfile(datapath, '*.nc'));
    for month=1:12
        % 获取每个文件的信息
        info_prec = ncinfo(fullfile(datapath, fileList1(ii).name));
        lon = ncread(fullfile(datapath, fileList1(ii).name), 'lon');
        lat = ncread(fullfile(datapath, fileList1(ii).name), 'lat');
        Prec = ncread(fullfile(datapath, fileList1(ii).name), 'Prec'); % 读取降雨量数据
        % 将-9999值替换为NaN
        Prec(Prec == -9999) = NaN;

        % 旋转处理后的数据
        Prec_rotated = rot90(Prec(:, :, 1), 1);

        % 指定输出文件名，保存为 .mat 文件
        outputFileName = fullfile(outputFolder, sprintf('%d_%02d.mat', year, month));

        % 保存数据为 .mat 文件
        save(outputFileName, 'Pre');
         outputFileName = sprintf('%d_%02d.tif', year, month);
        output_tiff_file = fullfile(outputFolder, outputFileName);
        geotiffwrite(output_tiff_file, Prec_rotated, info.RefMatrix);

    end
end



