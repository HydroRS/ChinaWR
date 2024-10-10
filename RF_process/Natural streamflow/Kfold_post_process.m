function [Kfold_accuracy] = Kfold_post_process(YTest, YPred)
%KFOLD_POST_PROCESS 此处显示有关此函数的摘要
%   做每一轮交叉验证的精度计算

% KGE = zeros(size(YTest, 1), 1);
% R2 = zeros(size(YTest, 1), 1);
% RMSE = zeros(size(YTest, 1), 1);
% NSE = zeros(size(YTest, 1), 1);
% MAE = zeros(size(YTest, 1), 1);
% Gama = zeros(size(YTest, 1), 1);
% Beta = zeros(size(YTest, 1), 1);
% Classfication = zeros(size(YTest, 1), 1);
% CC = zeros(size(YTest, 1), 1);
KGE=[];
R2=[];
RMSE=[];
NSE=[];
MAE=[];
Gama=[];
Beta=[];
Classfication=[];
CC=[];
for ii = 1:size(YTest, 1)
    % 计算当前行中的 NaN 值数量
    nan_count = sum(isnan(YTest(ii, :)));
    
    % 如果 NaN 值数量超过 10，则跳过该行
    if nan_count >5
        continue;
    end
    
    % 获取当前行数据
    Ydata_ii = YTest(ii, :);
    Ypre_ii = YPred(ii, :);
    
    % 删除含有 NaN 值的列
    nan_columns = isnan(Ydata_ii);
    Ydata_ii(:, nan_columns) = [];
    Ypre_ii(:, nan_columns) = [];
    
    % 计算各项指标
    K= objective_estimate_all(2, Ydata_ii, Ypre_ii);
    R22 = objective_estimate_all(3, Ydata_ii, Ypre_ii);
    R= objective_estimate_all(4, Ydata_ii, Ypre_ii);
    N = objective_estimate_all(1, Ydata_ii, Ypre_ii);
    M = objective_estimate_all(5, Ydata_ii, Ypre_ii);
    G = objective_estimate_all(6, Ydata_ii, Ypre_ii);
    B= objective_estimate_all(7, Ydata_ii, Ypre_ii);
    Cl= objective_estimate_all(9, Ydata_ii, Ypre_ii);
    C = corr(Ydata_ii', Ypre_ii');
    KGE=[KGE;K];
    R2=[R2;R22];
    RMSE=[RMSE;R];
    NSE=[NSE;N];
    MAE=[MAE;M];
    Gama=[Gama;G];
    Beta=[Beta;B];
    Classfication=[Classfication;Cl];
    CC=[CC;C];
end

Kfold_accuracy.KGE = KGE;
Kfold_accuracy.R2 = R2;
Kfold_accuracy.RMSE = RMSE;
Kfold_accuracy.NSE = NSE;
Kfold_accuracy.MAE = MAE;
Kfold_accuracy.Gama = Gama;
Kfold_accuracy.Beta = Beta;
Kfold_accuracy.Classfication = Classfication;
Kfold_accuracy.CC = CC;