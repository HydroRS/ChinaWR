function [rows_all_range, cols_all_range] = calculate_ranges(lat_row_tif, long_col_tif, bbox)
    rows_all = {};
    cols_all = {};
    for i = 1:length(lat_row_tif)
        [rows, cols] = rectangle_next_to_polygon(lat_row_tif{i}, long_col_tif{i}, bbox);
        rows_all{i} = lat_row_tif{i}(rows(1):rows(2));
        cols_all{i} = long_col_tif{i}(cols(1):cols(2));
    end
    
    [min_length_row, min_index_row] = min(cellfun(@length, rows_all));
    [min_length_col, min_index_col] = min(cellfun(@length, cols_all));
    
    min_vector_row = rows_all{min_index_row};
    min_vector_col = cols_all{min_index_col};
    
    rows_all_range = {};
    cols_all_range = {};
    for i = 1:length(lat_row_tif)
        rows_all_range{i} = [min(knnsearch(lat_row_tif{i}, min_vector_row)), max(knnsearch(lat_row_tif{i}, min_vector_row))];
        cols_all_range{i} = [min(knnsearch(long_col_tif{i}, min_vector_col)), max(knnsearch(long_col_tif{i}, min_vector_col))];
    end
end
