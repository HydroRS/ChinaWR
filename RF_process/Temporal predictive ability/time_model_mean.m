clc; clear;

% 定义保存结果的变量
all_testy = cell(1, 10);
all_prey = cell(1, 10);
rmse2 = [];
R22 = [];
KGE2 = [];
CC2 = [];

% 定义保存每次迭代结果的矩阵
iteration_results = zeros(4, 10);

for iter = 1:10

    %% 导入数据
    WaterRR_Data = xlsread('地表水数据.xlsx');
    idx=xlsread('D:\行政区索引.xlsx');
    liuyu_idx=xlsread('D:\九大流域索引.xlsx');

    % 参数设置
    leaf = 5;
    ntrees = 500;
    fboot = 1;
    surrogate = 'off';
    kfold = 5;
    Number_City = 357;
    DeltaYear = 10;
    City_LiuYu = liuyu_idx(1:Number_City,:);
    trainDataCell = cell(5, 2);

    % 构建矩阵，保存预测好的数据
    Predict = zeros(Number_City, DeltaYear);
    %% 提取样本
    [sum_traindata,sum_trainy,sum_test,sum_traintest]= extract_timeprocess(WaterRR_Data,liuyu_idx);

    % 选择2000-2010年的数据作为训练集
    train_data = sum_traindata;
    train_y = sum_trainy;

    % 选择2011-2020年的数据作为测试集
    test_data = sum_traintest;

    %% RF，对每一折进行预测
    mdl = TreeBagger(ntrees,train_data(:,1:end),train_y,'Method','regression','oobvarimp','on','surrogate',surrogate,'minleaf',leaf,'FBoot',fboot);
    PreditTest=predict(mdl,test_data(:,1:end)); % 预测的2011-2020年数据
    PredicT = reshape(PreditTest, [], 10);


    % 去除异常省份
    reshaped_data_test = reshape(WaterRR_Data(:, end), 357, 21);
    data_test = reshaped_data_test(:, 12:21);
    testy = data_test(idx, :);
    prey = Predict(idx, :);

    %     reshaped_data_prey = reshape(prey, [],1);
    %     reshaped_data_test = reshape(testy, [],1);
    all_testy{iter} = testy;
    all_prey{iter} = prey;
    % 查找全为 NaN 的行并删除
    nan_rows = all(isnan(testy), 2);
    testy = testy(~nan_rows, :);
    prey = prey(~nan_rows, :);
    nan_rows_indices = find(nan_rows);

    % 评估精度
    [Kfold_accuracy] = Kfold_post_process(testy,prey);
    KGE = Kfold_accuracy.KGE;
    R2 = Kfold_accuracy.R2;
    cc = Kfold_accuracy.CC;
    rmse = Kfold_accuracy.RMSE;
    % 保存评估结果到矩阵
    iteration_results(:, iter) = [median(R2); median(KGE); median(cc); median(rmse)];

    % 累积结果
    R22 = [R22,R2];
    KGE2 = [KGE2,KGE];
    CC2 = [CC2,cc];
    rmse2 = [rmse2,rmse];
end
% 保存测试数据和预测结果

testy=[];prey=[];

% 计算测试数据和预测结果的平均值
% 初始化空矩阵，用于存放每行每列的平均值
avg_testy_matrix = zeros(size(all_testy{1}));
avg_prey_matrix = zeros(size(all_prey{1}));

% 遍历每个单元格中的矩阵
for iter = 1:numel(all_testy)
    % 累加每个矩阵的值
    avg_testy_matrix = avg_testy_matrix + all_testy{iter};
    avg_prey_matrix = avg_prey_matrix + all_prey{iter};
end

% 计算平均值
avg_testy_matrix = avg_testy_matrix / numel(all_testy);
avg_prey_matrix = avg_prey_matrix / numel(all_prey);
avg_testy= reshape(avg_testy_matrix, [], 1);
avg_prey= reshape(avg_prey_matrix, [], 1);
% 将平均值矩阵保存起来

xlswrite('avg_testy_matrix_dbs.xlsx', avg_testy_matrix);
xlswrite('avg_prey_matrix_dbs.xlsx', avg_prey_matrix);
xlswrite('avg_testy_dbs.xlsx', avg_testy);
xlswrite('avg_prey_dbs.xlsx',avg_prey);

% 保存平均测试数据和预测结果到 Excel 文件
xlswrite('KGE_dbs.xlsx', KGE2);
xlswrite('R2_dbs.xlsx', R22);
xlswrite('CC_dbs.xlsx', CC2);
xlswrite('rmse_dbs.xlsx', rmse2);
xlswrite('iteration_results_dbs.xlsx', iteration_results);
avg_prey_matrix= xlsread('avg_prey_matrix_dbs.xlsx');
