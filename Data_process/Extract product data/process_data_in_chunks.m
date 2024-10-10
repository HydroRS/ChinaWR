function processed_data = process_data_in_chunks(data, chunk_size)
    [rows, cols] = size(data);  % 获取矩阵的行数和列数
    num_chunks = ceil(rows / chunk_size);  % 计算分块数目
    processed_data = zeros(rows, cols,'uint8');  % 创建用于存储处理后的数据的矩阵

    for i = 1:num_chunks
        ['chunks',num2str(i)]
        start_row = (i-1) * chunk_size + 1;
        end_row = min(i * chunk_size, rows);
        chunk = data(start_row:end_row, :);

        % 在此处进行分块处理
        processed_chunk = chunk;
        processed_chunk(processed_chunk ~= 1) = 0;

        processed_data(start_row:end_row, :) = processed_chunk;  % 将处理后的分块复制到结果矩阵的对应位置
    end
end
