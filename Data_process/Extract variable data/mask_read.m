function [ mask ] = mask_read( x,y,infor,data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%        x=province(kk).X;
%         y=province(kk).Y;
     chunk_size=10000;
        id=find(isnan(x));
        sart_id=0;
        mask=zeros(size(data),'uint8');
        for ii=1:length(id)
            disp(['polygon',num2str(ii)])
            current_polygon_x=x(sart_id+1:(id(ii)-1));
            current_polygon_y=y(sart_id+1:(id(ii)-1));
            sart_id=id(ii);
            
            x_index = round((current_polygon_x - infor.RefMatrix(3,1)) / infor.RefMatrix(2,1));
            y_index = round((current_polygon_y - infor.RefMatrix(3,2)) / infor.RefMatrix(1,2));
            mask_temp = poly2mask(x_index, y_index, size(data,1), size(data,2));
            mask=mask+uint8(mask_temp);
            %clear mask_temp
        end
%           mask(mask>0)=1; % 边界重合的地方，可能存在mask的值大于1的情况
          mask = process_data_in_chunks_mask(mask, chunk_size);% 边界重合的地方，可能存在mask的值大于1的情况
    
end

