clc;clear;
outputFolder='C:\grun\';
%% 1、读取GRUNnc数据
info_qtot = ncinfo('GRUN_v1_GSWP3_WGS84_05_1902_2014.nc'); % 查看变量
lon = ncread('GRUN_v1_GSWP3_WGS84_05_1902_2014.nc','X'); % 读取经度
lat = ncread('GRUN_v1_GSWP3_WGS84_05_1902_2014.nc','Y');  % 读取纬度
time = ncread('GRUN_v1_GSWP3_WGS84_05_1902_2014.nc','time');  % 读取时间
qtot = ncread('GRUN_v1_GSWP3_WGS84_05_1902_2014.nc','Runoff');
start_day=[2000,1,1];
end_day=[2014,12,31];
sum_month=12;
%% 2、读取tiff数据
nonvalue = 65535; % 无效值
info = geotiffinfo('city_china_357_PolygonToRast141.tif');
tif = imread('city_china_357_PolygonToRast141.tif');
[data_tiff,R]=readgeoraster('city_china_357_PolygonToRast141.tif');%404x485
year_qtot_ly=double(data_tiff);  % double化的矩阵 404*485
Water=year_qtot_ly(:);
simu_data = zeros(size(Water), 'single');
[row,col]=find(year_qtot_ly ~= nonvalue);
% obtaining coordinates of the projected system （pix2map)
[lat_ly,lon_ly] = pix2map(info.RefMatrix, row,col);
% obtaining coordinates of the geographical system
% [lat_ly,lon_ly] = projinv(info,x,y);  %将投影坐标转换为地理坐标
ShengFen_linearIdx = sub2ind(size(year_qtot_ly), row,col);
Water_ShengFen = year_qtot_ly(ShengFen_linearIdx);

temp_month_qtot=qtot(:,:,1);
temp_month_qtot(isnan(temp_month_qtot))=0;
[x_qtot,y_qtot]=find(zeros(size(qtot(:,:,1)))<10e8)
X_qtot=lon(x_qtot);
Y_qtot=lat(y_qtot);

%% 3、获取最邻近坐标-匹配坐标的径流
[idx_verify,distance_verify]=knnsearch([X_qtot,Y_qtot],[lat_ly,lon_ly],'k',1, 'Distance', 'euclidean');
% qtot_liuyu=temp_month_qtot(idx_verify);%每个索引分配属性
%% 分配
data_qtot=[];data_sumyear=[];
for year=start_day(1):end_day(1)
    temp_month_qtot=[];
    Ly_year_mean=[];month_data=[];
    for month=1:sum_month
        numday=eomday(year,month);
        t=month+(year-1902)*12;
        temp_month_qtot=qtot(:,:,t);
        qtot_liuyu=temp_month_qtot(idx_verify);%根据索引分配属性
        Ly_month_mean=[];qtot_liuy=[];Ly_mean_qtot=[];
        %% 按流域属性进行分类
        for a=0:356
            indices = find(Water_ShengFen == a);
            water_indices =ShengFen_linearIdx(indices);
            qtot_liuy=qtot_liuyu(Water_ShengFen==a); %每个流域进行分配
            Ly_mean_qtot=qtot_liuy(~isnan(qtot_liuy));%去除掉是NAN的函数
            ly_qtot=nanmean(Ly_mean_qtot);%求一下月平均径流深
            ly_qtot=ly_qtot*numday*24;
            Ly_month_mean=[Ly_month_mean;ly_qtot];
            simu_data(water_indices, 1) = qtot_liuy.*numday.*24;
        end
        Ly_year_mean =[Ly_year_mean ,Ly_month_mean];
        month_data =[month_data ,simu_data];
    end
    data_qtot=mean(month_data,2);
    data_mean=mean(Ly_year_mean,2);
    data_double=double(data_qtot);
    geo_data=reshape(data_double,393,688);
    % geo_data=reshape(data_pre,3938,6869);
    % 创建要保存的文件名
    output_filename = fullfile(outputFolder, ['grun_', num2str(year), '.tif']);
    geotiffwrite(output_filename, geo_data,info.RefMatrix);
    data_qtot=[data_qtot;data_mean];
    data_sumyear=[data_sumyear,data_double];
end
data_double=mean(data_sumyear,2);
geo_data=reshape(data_pre,393,688);
% 创建要保存的文件名
output_filename = fullfile(outputFolder, ['grun.tif']);
geotiffwrite(output_filename, geo_data,info.RefMatrix);
writematrix(data_qtot,'grun_year.xlsx');