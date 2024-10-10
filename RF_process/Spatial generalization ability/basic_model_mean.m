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
    WaterRR_Data = xlsread('地下水数据.xlsx');
    idx=xlsread('D:\行政区索引.xlsx');
    liuyu_idx=xlsread('D:\九大流域索引.xlsx');

    % 参数设置
    leaf = 5;
    ntrees = 500;
    fboot = 1;
    surrogate = 'off';
    kfold = 5;
    Number_City = 357;
    DeltaYear = 21;
    City_LiuYu = liuyu_idx(1:Number_City,:);
    trainDataCell = cell(5, 2);
    
    % 五折
    SubregionCelltest = importdata('SubregionCelltest.mat');
    SubregionCelltrain = importdata('SubregionCelltrain.mat');
    
    % 构建矩阵，保存预测好的数据
    Predict = zeros(Number_City, DeltaYear);
    for kk=1:5
        Train_indices=SubregionCelltrain{kk};
        Test_indices=SubregionCelltest{kk};
        %% 提取样本
        [sum_traindata,sum_trainy,sum_test]= extract_process(WaterRR_Data,liuyu_idx,SubregionCelltrain,SubregionCelltest,kk);
        %% RF，对每一折进行预测
        trainDataCell{kk, 1} = sum_traindata; % 保存 sum_traindata
        trainDataCell{kk, 2} = sum_test; % 保存 sum_trainy
        mdl = TreeBagger(ntrees,sum_traindata(:,1:end),sum_trainy,'Method','regression','oobvarimp','on','surrogate',surrogate,'minleaf',leaf,'FBoot',fboot);
        PreditTest=predict(mdl,sum_test(:,1:end));%预测的20%的数据
        vail_pre=reshape(PreditTest,length(Test_indices),21);
        Predict(Test_indices,:) = vail_pre;
    end

    % 去除异常省份
    reshaped_data_test = reshape(WaterRR_Data(:,end), 357,21);
    testy=reshaped_data_test(idx,:);
    prey=Predict(idx,:);

    % 评估精度
    [Kfold_accuracy] = Kfold_post_process(testy,prey);
    R2 = Kfold_accuracy.R2;
    KGE = Kfold_accuracy.KGE;
    cc = Kfold_accuracy.CC;
    rmse = Kfold_accuracy.RMSE;
    % 保存评估结果到矩阵
    iteration_results(:, iter) = [median(R2); median(KGE); median(cc); median(rmse)];
    
    % 累积结果
    R22 = [R22,R2];
    KGE2 = [KGE2,KGE];
    CC2 = [CC2,cc];
    rmse2 = [rmse2,rmse];

    % 保存测试数据和预测结果
    all_testy{iter} = testy;
    all_prey{iter} = prey;
    testy=[];prey=[];
end

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
xlswrite('avg_testy_matrix_dxs.xlsx', avg_testy_matrix);
xlswrite('avg_prey_matrix_dxs.xlsx', avg_prey_matrix);
xlswrite('avg_testy_dxs.xlsx', avg_testy);
xlswrite('avg_prey_dxs.xlsx',avg_prey);

% 保存平均测试数据和预测结果到 Excel 文件
xlswrite('KGE_dxs.xlsx', KGE2);
xlswrite('R2_dxs.xlsx', R22);
xlswrite('CC_dxs.xlsx', CC2);
xlswrite('rmse_dxs.xlsx', rmse2);
xlswrite('iteration_results_dxs.xlsx', iteration_results);
avg_prey_matrix= xlsread('C:\avg_prey_matrix_dxs.xlsx');
