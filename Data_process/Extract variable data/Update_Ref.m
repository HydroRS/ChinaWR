function [ infor ] = Update_Ref( tif_file,long_col_tif,lat_row_tif,UL_corner_X,UL_corner_Y )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
       infor=geotiffinfo(tif_file);
         infor.RefMatrix(3,1)=long_col_tif(UL_corner_X)-infor.PixelScale(1);
        infor.RefMatrix(3,2)=lat_row_tif(UL_corner_Y)+infor.PixelScale(1);

end

