clc;
clear;
base_folder = 'E:\0.01';  
dem =imread('E:\dem0.01.tif'); % 修改为 DEM 数据的文件夹路径
dem_geo= geotiffinfo('E:\dem0.01.tif');
outputFolderPath = 'E:\地表水0.01\';
data1 = readmatrix('D:\地表水数据.xlsx');
dem_re=reshape(dem,27050122,1);
dem_data=find(dem~=-32768);
simu_data=zeros(size(dem_re));
% 初始化存储所有图像数据的结构
all_images = [];matches=[];matches_images=[];t=[];t1=[];t2=[];tt=[];
%% 将行政区的数据先进行训练
leaf = 5;
ntrees = 500;
fboot = 1;
surrogate = 'off';
kfold = 5;
XTrain_c = data1(2:end, 4:end-1);
YTrain_c = data1(2:end, end);
mdl_c = TreeBagger(ntrees, XTrain_c, YTrain_c, 'Method', 'regression',  'oobvarimp', 'on', 'surrogate', surrogate, 'minleaf', leaf, 'FBoot', fboot);
%% 开始提取每个变量的TIFF数据
% 遍历两个文件夹（假设这两个文件夹位于大文件夹内）
for i=1:21
    all_images=[]; u=1999+i;
    subfolders = dir(fullfile(base_folder, '*'));
    for folder_index = 3:15
        if subfolders(folder_index).isdir && ~strcmp(subfolders(folder_index).name, '.') && ~strcmp(subfolders(folder_index).name, '..')
            subfolder_name = subfolders(folder_index).name;
            % 获取当前子文件夹的完整路径
            current_folder = fullfile(base_folder, subfolder_name);
            % 遍历当前子文件夹中的文件夹
            tiff_files = dir(fullfile(current_folder, '*.tif'));
            if length(tiff_files) == 1
                % 如果当前子文件夹只有一个TIFF图像文件，将其reshape成27050122*1的矩阵，并重复19次270384
                image = imread(fullfile(current_folder, tiff_files(1).name));
                image_data = reshape(image,270384, 1);
                matches3 = image_data(dem_data,:);
                matches_images=double(matches3);
            elseif length(tiff_files) == 21
                % 如果当前子文件夹中有19个TIFF图像文件，处理每个图像并将它们concatenate成一列
                for tiff_index = i
                    image_data=[];
                    image = imread(fullfile(current_folder, tiff_files(i).name));
                    image_data = reshape(image, 270384, 1);
                    matches1 = image_data(dem_data,:);
                    matches_images=double(matches1);
                end
                   matches = [matches, matches_images];
            end
            all_images = [all_images, matches_images];
            matches=[];matches_images=[];
        end
    end
    %% 地表水预测
    XTest = all_images(:, :); % 使用整个格网数据作为测试集
    y_vali = predict(mdl_c, XTest);%预测水资源
    simu_data(dem_data,1)=y_vali;
    data_pre=double(simu_data);
    geo_data=reshape(data_pre,3938,6869);
    % 创建要保存的文件名
    output_filename = fullfile(outputFolderPath, [num2str(u),'.tif']);
    % 使用 geotiffwrite 函数将数据写入 GeoTIFF 文件
  geotiffwrite(output_filename, geo_data, dem_geo.RefMatrix);
end