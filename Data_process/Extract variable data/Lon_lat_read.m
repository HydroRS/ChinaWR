function [ lat_row_tif,long_col_tif ] = Lon_lat_read( tif_file )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     tif_file = [tif_folder, 'CNLC', num2str(cropland_year(jj)),'.tif'];
    data_GeoInfor=geotiffinfo(tif_file);
    % 读取tif各行的纬度以及各列的经度
    num_rows = data_GeoInfor.Height;
    num_cols = data_GeoInfor.Width;
    [x1,y1]= pix2latlon(data_GeoInfor.RefMatrix, (1:num_rows)',ones(num_rows,1)); % 行
    [x2,y2]= pix2latlon(data_GeoInfor.RefMatrix, ones(num_cols,1),(1:num_cols)'); % 列
    % 地理坐标
    lat_row_tif=x1;
    long_col_tif=y2;
%     clear x1;clear y1;clear x2;clear y2;

end
