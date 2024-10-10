clc;
clear;


[County_infor_sk, County_name_sk] = xlsread('C:\XX.xlsx');
County_name_sk(1, :) = []; 
id_name_sk = County_name_sk(:,5); 
province_id_sk = unique(County_infor_sk(:, 1)); 
shp_pro_file_sk = 'D:\XX.shp';
County_table_sk = shaperead(shp_pro_file_sk);

County_data_folder = 'D:\';
fileList = dir(fullfile(County_data_folder, '*.tif')); % tif

tiff_filename = fullfile(County_data_folder, fileList(1).name);
dem_re=imread(fullfile(County_data_folder, fileList(1).name));
[row_count, column_count, ~] = size(dem_re);
simu_data=zeros(size(dem_re),'single');

current_province_infor = geotiffinfo(tiff_filename);
[lat_row_tif, long_col_tif] = Lon_lat_read(tiff_filename);

dem_geo= geotiffinfo(tiff_filename);

for kk = 1:length(province_id_sk)
    id_County = find(County_infor_sk(:,1) == province_id_sk(kk));

    bbox_sk = County_table_sk(kk).BoundingBox;

    [rows_all_range_sk, cols_all_range_sk] = calculate_ranges({lat_row_tif}, {long_col_tif}, bbox_sk);

    current_province_infor_update = Update_Ref(tiff_filename, long_col_tif, lat_row_tif, cols_all_range_sk{1}(1), rows_all_range_sk{1}(1));
    data_County = imread(tiff_filename, 'PixelRegion', {rows_all_range_sk{1}, cols_all_range_sk{1}});
    mask = mask_read(County_table_sk(id_County(1), :).X, County_table_sk(id_County(1), :).Y, current_province_infor_update, data_County);
    aa=rows_all_range_sk{1};
    bb= cols_all_range_sk{1};

    simu_data(aa(1):aa(2), bb(1):bb(2)) = mask(:, :);
end
data=double(simu_data(:));
geo_data=reshape(data,row_count, column_count);

output_filename = 'XX.tiff';
geotiffwrite(output_filename, simu_data, dem_geo.RefMatrix);
disp(['Output TIFF file saved as: ', output_filename]);
