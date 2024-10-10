clc;
clear;
outputFolderPath1 = '\';

%% 读取省份信息
[County_infor, County_name] = xlsread('D:\city_china_357_info.xls');
province_id = unique(County_infor(:, 1)); % 没有id就按照FID
shp_pro_file =  'D:\city_china_357.shp';

County = shaperead(shp_pro_file);
% 读取参考 TIFF 文件的地理信息
reference_tiff = 'D:\DEM0.01_New.tif';
info = geotiffinfo(reference_tiff);
[reference_data, R] = readgeoraster(reference_tiff);

% 数据文件夹
County_data_folder = 'C:\soil\';
fileList = dir(fullfile(County_data_folder, '*.tif')); % 获取所有tif文件列表

% 按文件名排序
[~, idx] = sort({fileList.name});
fileList = fileList(idx);

% 初始化用于存储所有年份结果的cell数组
all_final_results = zeros(size(reference_data), 'single');
all_result=[];


% 初始化用于计算平均值的矩阵
final_result = nan(size(reference_data), 'single');
result = [];
month_day_count = 0;  % 记录当月的天数

% 构建文件名: Prec_year2000_day1.tif ~ Prec_year2000_day365.tif
fileName = sprintf('PDEP.tif');
filePath = fullfile(County_data_folder, fileName);

% 检查文件是否存在
if exist(filePath, 'file')
    %% 获取当前省份的tiff信息
    ct = filePath;
    PRE_TIF = imread(ct);
    PRETIF_info = geotiffinfo(ct);
    [TIF_n, TIF_m] = size(PRE_TIF);
    PRE_year_qtot_min = double(PRE_TIF);
    [TIF_lat, ~] = pix2latlon(PRETIF_info.RefMatrix, (1:TIF_n)', ones(TIF_n, 1));
    [~, TIF_lon] = pix2latlon(PRETIF_info.RefMatrix, ones(TIF_m, 1), (1:TIF_m)');

    for kk = 1:length(province_id)
        id_County = find(County_infor(:, 1) == province_id(kk));
        bbox = County(id_County).BoundingBox;

        % 计算省份外接矩形的位置和大小
        lat_row_tif_cell = {TIF_lat};
        long_col_tif_cell = {TIF_lon};
        [rows_all_range, cols_all_range] = calculate_ranges(lat_row_tif_cell, long_col_tif_cell, bbox);

        % 读取当前County的数据
        current_province_infor_update = Update_Ref(ct, TIF_lon, TIF_lat, cols_all_range{1}(1), rows_all_range{1}(1));
        data_County = imread(ct, 'PixelRegion', {rows_all_range{1}, cols_all_range{1}});
        data_County(isnan(data_County)) = 0;
        if all(data_County(:) == 0)
            lon_Ind = knnsearch(TIF_lon, mean(bbox(:,1))); % 前面的经纬度找后面的经纬度
            lat_Ind = knnsearch(TIF_lat, mean(bbox(:,2)));
            Station_linearInd = sub2ind(size(PRE_TIF), lat_Ind, lon_Ind);
            daily_pre_data = PRE_year_qtot_min(Station_linearInd);
        else
            % 创建掩码
            mask = mask_read(County(id_County(1)).X, County(id_County(1)).Y, current_province_infor_update, data_County);
            if all(mask(:) == 0)
                lon_Ind = knnsearch(TIF_lon, County(id_County(1)).X); % 前面的经纬度找后面的经纬度
                lat_Ind = knnsearch(TIF_lat, County(id_County(1)).Y);
                Station_linearInd = sub2ind(size(PRE_TIF), lat_Ind, lon_Ind);
                mask_data = PRE_year_qtot_min(Station_linearInd);
            else
                mask_data = double(mask);
            end

            data_County(data_County == -3.4028231e+38) = 0;
            data_County(data_County <0) = 0;
            county_data = double(data_County);
            mask_double = mask_data(:);
            aa = sum(mask_double);

            pre_data = mask_data .* county_data;
            daily_pre = double(pre_data(:));
            bb = sum(daily_pre);
            daily_pre_data = bb / aa;
            if isnan(daily_pre_data)
                daily_pre_data = 0;
            end
        end
        result = [result; daily_pre_data];

        % 将当前County的值写入最终结果矩阵
        [row_indices, col_indices] = meshgrid(rows_all_range{1}, cols_all_range{1});
        final_result(row_indices(1, 1):row_indices(1, 2), col_indices(1, 1):col_indices(2, 1)) = data_County;
    end

    % 增加当月天数
    month_day_count = month_day_count + 1;
end

% 存储每个月的final_result到cell数组
all_final_results = all_final_results+final_result;
all_result=[all_result,result];
output_tiff_file = fullfile(outputFolderPath1, sprintf('data%0d.tif', year));
geotiffwrite(output_tiff_file, all_final_results./11, info.RefMatrix);
% 将所有年的final_result保存为MAT文件
output_mat_file = fullfile(outputFolderPath1, 'all_final_results.mat');
save(output_mat_file, 'all_final_results');
% 将每个月的result保存为Excel文件
output_excel = fullfile(outputFolderPath1, sprintf('PDEP_result.xlsx'));
writematrix(all_result, output_excel);