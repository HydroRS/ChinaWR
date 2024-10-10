clc; clear;

DemPath = '\';
Outpath = '\';

startYear = 1980;
endYear = 2020;

% 读取 0.01 度 DEM
[Dem001_data, ~] = readgeoraster('D:\DEM0.01_New.tif');
TIF_info1 = geotiffinfo('D:\DEM0.01_New.tif');
[m1, n1] = find(Dem001_data ~= -32768);
Grid_linearIdx001 = sub2ind(size(Dem001_data), m1, n1);
[Grid_lon001, Grid_lat001] = pix2map(TIF_info1.RefMatrix, m1, n1);
[TIF_n1, TIF_m1] = size(Dem001_data);
[lat_001, ~] = pix2latlon(TIF_info1.RefMatrix, (1:TIF_n1)', ones(TIF_n1, 1));
[~, lon_001] = pix2latlon(TIF_info1.RefMatrix, ones(TIF_m1, 1), (1:TIF_m1)');

% 读取 0.1 度 DEM
[DemTIF_01, geographic_R] = readgeoraster('D:\DEM0.1_New.tif');
TIF_info = geotiffinfo('D:\DEM0.1_New.tif');
[m2, n2] = find(DemTIF_01 ~= -32768);
Grid_linearIdx01 = sub2ind(size(DemTIF_01), m2, n2);
[Grid_lon, Grid_lat] = pix2map(TIF_info.RefMatrix, m2, n2);
[TIF_n2, TIF_m2] = size(DemTIF_01);
[lat_01, ~] = pix2latlon(TIF_info.RefMatrix, (1:TIF_n2)', ones(TIF_n2, 1));
[~, lon_01] = pix2latlon(TIF_info.RefMatrix, ones(TIF_m2, 1), (1:TIF_m2)');

% 最近邻的 10x10
nearest_k = 10;
mask_lon = knnsearch(lon_001, Grid_lon, 'k', nearest_k);
mask_lat = knnsearch(lat_001, Grid_lat, 'k', nearest_k);

% 最近邻 1 个，若出现 nan，从最近邻 1 个直接提取
nearest_Ind = knnsearch([Grid_lon001, Grid_lat001], [Grid_lon, Grid_lat]);
save([Outpath, '0.1度有效网格对应0.01度有效网格的最近索引.mat'], 'nearest_Ind', '-v7.3');

for Year = startYear:endYear
    for month = 1:12
        current_day = 1;

        Final_outPath = [Outpath];

        if ~exist(Final_outPath, 'dir')
            mkdir(Final_outPath);
        end

        % 读取NetCDF数据
        % 构建完整的NetCDF文件路径
        ncFilePath = fullfile(DemPath, sprintf('ChinaWR_GWR_001deg_%04d_%02d.nc', Year, month));

        % 读取NetCDF文件中的“Groundwater recharge (GWR)”变量
        ncData = ncread(ncFilePath, 'Groundwater recharge (GWR)'); % 替换为NetCDF变量名
        ncData=rot90(ncData);

        % 插值处理 NetCDF 数据 (将 0.01度 升尺度到 0.1度)
        ThisDay_01 = single(zeros(length(Grid_lon), 1));
        for ii = 1:length(Grid_lon)
            mask_row = mask_lat(ii, :)';
            mask_col = mask_lon(ii, :)';
            temp_mask = ncData(mask_row, mask_col);
            temp_mean = nanmean(temp_mask(:)); % 取周围的平均值来升尺度
            ThisDay_01(ii, 1) = temp_mean;
        end

        % 如果存在 NaN 值，用最近邻插值处理
        if any(isnan(ThisDay_01))
            nan_Ind = find(isnan(ThisDay_01));
            nan_nearest = nearest_Ind(nan_Ind);
            ThisDay_01(nan_Ind) = ncData(nan_nearest);
        end

        simu_data(Grid_linearIdx01, 1) = ThisDay_01;
        updata = reshape(simu_data, 393, 688);

        % 保存为 TIFF 文件
        outputFileName = [Outpath, sprintf('ChinaWR_GWR_010deg_%04d_%02d.tif', Year, month)];
        geotiffwrite(outputFileName, updata, TIF_info.RefMatrix);

        current_day = current_day + 1;
    end
end
