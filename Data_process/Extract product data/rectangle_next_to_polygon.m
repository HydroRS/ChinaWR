function [ rows,cols ] = rectangle_next_to_polygon( lat_row_tif,long_col_tif, bbox )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

max_row = find(lat_row_tif <= min(bbox(:, 2))); % Locations below the matrix
if isempty(max_row)
    max_row=length(lat_row_tif);
end
min_row = find(lat_row_tif >= max(bbox(:, 2))); % Locations above the matrix
if isempty(min_row)
    min_row=1;
end

min_col = find(long_col_tif <= min(bbox(:, 1))); % Locations to the left of the matrix
if isempty(min_col)
    min_col=1;
end

max_col = find(long_col_tif >= max(bbox(:, 1))); % Locations to the right of the matrix
if isempty(max_col)
    max_col=length(long_col_tif);
end

rows=[min_row(end), max_row(1)];
cols=[min_col(end), max_col(1)];

end

