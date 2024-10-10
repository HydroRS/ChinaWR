clc;
clear;

[County_infor, County_name] = xlsread('.xls');
County_name(1, :) = [];
id_name = County_name(:, 4);
province_id = unique(County_infor(:, 2)); 

shp_pro_file = '.shp';
County = shaperead(shp_pro_file);


last_data = [];
County_data_folder = 'E:\';
fileList = dir(fullfile(County_data_folder, '*.tif')); 


[~, idx] = sort({fileList.name});
fileList = fileList(idx);


years = 2000:2020; 
months = 1:12;


for year = years
    for month = months
    
        result = [];

  
        fileName = sprintf('%04d-%01d.tif.tif', year, month);
        filePath = fullfile(County_data_folder, fileName);

     
        if exist(filePath, 'file')
            
            ct = filePath;
            current_province_infor = geotiffinfo(ct);
            [lat_row_tif, long_col_tif] = Lon_lat_read(ct);
            
            for kk = 1:length(province_id)
                id_County = find(County_infor(:, 2) == province_id(kk));
                bbox = County(id_County).BoundingBox;
                
             
                lat_row_tif_cell = {lat_row_tif};
                long_col_tif_cell = {long_col_tif};
                [rows_all_range, cols_all_range] = calculate_ranges(lat_row_tif_cell, long_col_tif_cell, bbox);
                
                
                current_province_infor_update = Update_Ref(ct, long_col_tif, lat_row_tif, cols_all_range{1}(1), rows_all_range{1}(1));
                data_County = imread(ct, 'PixelRegion', {rows_all_range{1}, cols_all_range{1}});
                
              
                mask = mask_read(County(id_County(1)).X, County(id_County(1)).Y, current_province_infor_update, data_County);
                
              
                mask_data = double(mask);
                data_County(data_County == -3.4028231e+38) = 0;
                county_data = double(data_County);
                mask_double = mask_data(:);
                aa = sum(mask_double);
                
                pre_data = mask_data .* county_data;
                daily_pre = double(pre_data(:));
                bb = sum(daily_pre);
                daily_pre_data = bb ./ aa;
                if isnan(daily_pre_data)
                    daily_pre_data = 0;
                end
                result = [result; daily_pre_data];
            end
            last_data = [last_data; result];
        end
    end
end
last_data=reshape(last_data,[],1);

output_excel = '.xlsx';
writematrix(last_data, output_excel);
