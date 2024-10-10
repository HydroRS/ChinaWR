clc;clear;
outputFolder='C:\cnrd\';
%% 1、读取CNRDnc文件
info_qtot = ncinfo('CNRDv1.0_monthly_2001_2010.nc'); % 查看变量
lon = ncread('CNRDv1.0_monthly_2001_2010.nc','lon'); % 读取经度
lat = ncread('CNRDv1.0_monthly_2001_2010.nc','lat');  % 读取纬度
time = ncread('CNRDv1.0_monthly_2001_2010.nc','time');  % 读取时间
qtot = ncread('CNRDv1.0_monthly_2001_2010.nc','qtot');
start_day=[2001,1,1];
end_day=[2010,12,31];
sum_month=12;
%% 2、读取357个行政区tiff文件
info = geotiffinfo('city_china_357_PolygonToRast141.tif');
tif = imread('city_china_357_PolygonToRast141.tif');
[data_tiff,R]=readgeoraster('city_china_357_PolygonToRast141.tif');%404x485
year_qtot_ly=double(data_tiff);  % double化的矩阵 404*485
Water=year_qtot_ly(:);
[row,col]=find(year_qtot_ly<10e8);
% obtaining coordinates of the projected system （pix2map)
[lon_ly,lat_ly] = pix2map(info.RefMatrix, row,col);
% obtaining coordinates of the geographical system
% [lat_ly,lon_ly] = projinv(info,x,y);  %将投影坐标转换为地理坐标
ShengFen_linearIdx = sub2ind(size(year_qtot_ly), row,col);
Water_ShengFen = year_qtot_ly(ShengFen_linearIdx);
simu_data = zeros(size(Water), 'single');
%% 3、读取nc文件经纬度
temp_month_qtot=qtot(:,:,1);
temp_month_qtot(isnan(temp_month_qtot))=0;
[x_qtot,y_qtot]=find(zeros(size(qtot(:,:,1)))<10e8);
X_qtot=lon(x_qtot);
Y_qtot=lat(y_qtot);

%% 4、获取最邻近坐标-匹配坐标的径流
[idx_verify,distance_verify]=knnsearch([X_qtot,Y_qtot],[lon_ly,lat_ly],'k',1, 'Distance', 'euclidean');

%% 5、分配
data=[];
data_sumyear=[];
for year=start_day(1):end_day(1)
    temp_month_qtot=[];
    Ly_year_mean=[];
    month_data=[];
    for month=1:sum_month
        numday=eomday(year,month);
        t=month+(year-2001)*12;
        temp_month_qtot=qtot(:,:,t);
        qtot_liuyu=temp_month_qtot(idx_verify);%根据索引分配属性
        Ly_month_mean=[];
        qtot_liuy=[];
        Ly_mean_qtot=[];
        %% 按流域属性进行分类
        for a=0:356
            indices = find(Water_ShengFen == a);
            water_indices =ShengFen_linearIdx(indices);
            qtot_liuy=qtot_liuyu(Water==a); %每个流域进行分配
            Ly_mean_qtot=qtot_liuy(~isnan(qtot_liuy));%去除掉是NAN的函数
            ly_qtot=mean(Ly_mean_qtot);%求一下月平均径流深
            Ly_month_mean=[Ly_month_mean;ly_qtot];
            simu_data(water_indices, 1) = qtot_liuy;
        end
        Ly_year_mean =[Ly_year_mean ,Ly_month_mean];
        month_data =[month_data ,simu_data];
    end
    data_qtot=sum(Ly_year_mean,2);
    data_sum=sum(month_data,2);
    data_double=double(data_sum);
    geo_data=reshape(data_double,393,688);
    % 创建要保存的文件名
    output_filename = fullfile(outputFolder, sprintf('CNRD%04d.tif',year));
    geotiffwrite(output_filename, geo_data,info.RefMatrix);
    data=[data,data_sum];
    data_sumyear=[data_sumyear,data_double];
end
data_double=mean(data_sumyear,2);
geo_data=reshape(data_double,393,688);
%% 6、 创建要保存的文件名
output_filename = fullfile(outputFolder, ['cnrd.tif']);
geotiffwrite(output_filename, geo_data,info.RefMatrix);
writematrix(data,'CNRD.xls');
