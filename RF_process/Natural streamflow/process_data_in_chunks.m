function processed_data = process_data_in_chunks(data, chunk_size)
    [rows, cols] = size(data);  % ��ȡ���������������
    num_chunks = ceil(rows / chunk_size);  % ����ֿ���Ŀ
    processed_data = zeros(rows, cols,'uint8');  % �������ڴ洢���������ݵľ���

    for i = 1:num_chunks
        ['chunks',num2str(i)]
        start_row = (i-1) * chunk_size + 1;
        end_row = min(i * chunk_size, rows);
        chunk = data(start_row:end_row, :);

        % �ڴ˴����зֿ鴦��
        processed_chunk = chunk;
        processed_chunk(processed_chunk ~= 1) = 0;

        processed_data(start_row:end_row, :) = processed_chunk;  % �������ķֿ鸴�Ƶ��������Ķ�Ӧλ��
    end
end
