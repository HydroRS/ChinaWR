clc
clear

DemPath = fullfile('D:\');
Outpath = 'C:\';

startYear = 1980;
endYear = 2020;
This_variable = '';
dataPath = fullfile(Outpath);

%% DEM 读取
[DemTIF_data, geographic_R] = readgeoraster([DemPath, 'DEM.tif']);
DemTIF_data = double(DemTIF_data);
TIF_info = geotiffinfo([DemPath, 'DEM.tif']);
[m, n] = find(DemTIF_data ~= -32768);
Grid_linearIdx = sub2ind(size(DemTIF_data), m, n);
[TIF_n, TIF_m] = size(DemTIF_data);
[TIF_lat, ~] = pix2latlon(TIF_info.RefMatrix, (1:TIF_n)', ones(TIF_n, 1));
[~, TIF_lon] = pix2latlon(TIF_info.RefMatrix, ones(TIF_m, 1), (1:TIF_m)');
TIF_lat_flipud = flipud(TIF_lat);

%% 逐年处理
for Year = startYear:endYear
    year_samplength = num2str(Year, '%04d');
    for Month = 1:12
        month_samlength = num2str(Month, '%02d');
         month_samlength1 = num2str(Month, '%02d');
        Final_MonthlyOutPath = fullfile(Outpath, [This_variable, year_samplength,'_', month_samlength]);
        if ~exist(Final_MonthlyOutPath, 'dir')
            mkdir(Final_MonthlyOutPath);
        end
        Out_Monthly_Filename = [This_variable, '_', year_samplength, '_', month_samlength, '.nc'];
        out_MonthFile = fullfile(Out_Monthly_Filename);

        % 读取月份数据
        ThisMonth_name = [This_variable,'_',  year_samplength, '_', month_samlength1, '.tif'];
        ThisMonth_data = readgeoraster([dataPath, ThisMonth_name]);

        % 数据转换
        Monthly2nc = single(nan(TIF_n, TIF_m));
        Monthly2nc(Grid_linearIdx) = ThisMonth_data(Grid_linearIdx); % 替换成合适的数据处理方式
        Monthly2nc_rot90 = rot90(Monthly2nc, -1);

        % 打开文件，定义维度和变量
        ncid_monthly = netcdf.create(out_MonthFile, 'NETCDF4');
        % info.Dimensions
        lonDimId = netcdf.defDim(ncid_monthly, 'lon', length(TIF_lon));
        latDimId = netcdf.defDim(ncid_monthly, 'lat', length(TIF_lat));
        lonVarid = netcdf.defVar(ncid_monthly, 'lon', 'NC_FLOAT', lonDimId);
        latVarid = netcdf.defVar(ncid_monthly, 'lat', 'NC_FLOAT', latDimId);
        precVarid = netcdf.defVar(ncid_monthly, 'Groundwater recharge (GWR)', 'NC_FLOAT', [lonDimId, latDimId]);
        netcdf.defVarDeflate(ncid_monthly, precVarid, true, true,5);  % 开启shuffle, 开启deflate, 设置压缩级别为5
        netcdf.endDef(ncid_monthly);
        % 写入数据  info.Variables
        netcdf.putVar(ncid_monthly, lonVarid, TIF_lon);
        netcdf.putVar(ncid_monthly, latVarid, TIF_lat_flipud);
        netcdf.putVar(ncid_monthly, precVarid, Monthly2nc_rot90);
        % 设置属性 info.Variables里面的Attributes
        netcdf.putAtt(ncid_monthly, lonVarid, 'standard_name', 'longitude');
        netcdf.putAtt(ncid_monthly, lonVarid, 'units', 'degrees_east');
        netcdf.putAtt(ncid_monthly, lonVarid, 'axis', 'X');
        netcdf.putAtt(ncid_monthly, latVarid, 'standard_name', 'latitude');
        netcdf.putAtt(ncid_monthly, latVarid, 'units', 'degrees_north');
        netcdf.putAtt(ncid_monthly, latVarid, 'axis', 'Y');
        netcdf.putAtt(ncid_monthly, precVarid, 'long_name', 'monthly GWR');
        netcdf.putAtt(ncid_monthly, precVarid, 'units', 'mm/month');
        netcdf.putAtt(ncid_monthly, precVarid, 'missing_value','nan');
        % 添加全局属性
        % Add global attributes
    netcdf.putAtt(ncid_monthly, netcdf.getConstant('NC_GLOBAL'), 'Title', ...
        'ChinaWR: High-Resolution (1 km) Long-Term Gridded Water Resources Dataset for China');
    netcdf.putAtt(ncid_monthly, netcdf.getConstant('NC_GLOBAL'), 'Data Period', '1980-2020');
    netcdf.putAtt(ncid_monthly, netcdf.getConstant('NC_GLOBAL'), 'Author', ...
        'Dr. Ling Zhang, Email: zhanglingky@lzb.ac.cn, Northwest Institute of Eco-Environment and Resources, CAS');
        % 关闭文件
        netcdf.close(ncid_monthly);
        clear Monthly_Col Monthly2nc_rot90 Monthly2nc 
    end



end



