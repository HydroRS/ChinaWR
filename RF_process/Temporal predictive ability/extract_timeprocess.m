function [sum_traindata,sum_trainy,sum_test,sum_traintest] = extract_timeprocess(WaterRR_Data,liuyu_idx)
    start_train_year = 2000;
    end_train_year = 2020;
    start_test_year = 1980;
    end_test_year = 1999;
    
    sum_traindata = [];
    sum_trainy = [];
    sum_test = [];
    sum_traintest =[];
    
    
    % 提取2000年至2010年的训练数据
    for year = start_train_year:end_train_year
        DataIndices = find(liuyu_idx(:, 2) == year);
        Data = WaterRR_Data(DataIndices, :);

        TrainData = Data(:, 3:end-1);
        TrainY = Data(:, end);
        
        sum_traindata = [sum_traindata; TrainData];
        sum_trainy = [sum_trainy; TrainY];
    end
    
    % 提取2011年至2020年的测试数据
    for year = start_test_year:end_test_year
        DataIndices = find(liuyu_idx(:, 2) == year);
        Data = WaterRR_Data(DataIndices, :);
        
        TestData = Data(:,  3:end-1);
        TestY = Data(:, 3:end-1);
        sum_test = [sum_test; TestY];
        sum_traintest= [sum_traintest;TestData];
    end
end
