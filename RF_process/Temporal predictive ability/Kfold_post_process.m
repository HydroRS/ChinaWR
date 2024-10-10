function [Kfold_accuracy] = Kfold_post_process(YTest,YPred)%test_y真实值
%KFOLD_POST_PROCESS 此处显示有关此函数的摘要
%   做每一轮交叉验证的精度计算
KGE = zeros(size(YTest,1),1);
R2=zeros(size(YTest,1),1);
RMSE=zeros(size(YTest,1),1);
NSE=zeros(size(YTest,1),1);
MAE=zeros(size(YTest,1),1);
Gama=zeros(size(YTest,1),1);
Beta=zeros(size(YTest,1),1);
Classfication=zeros(size(YTest,1),1);
CC=zeros(size(YTest,1),1);

for ii=1:size(YTest,1)
    % 检查当前行是否有NaN值
    if any(isnan(YTest(ii, :)))
        % 删除含有NaN值的列
        % 检查第一组数据中是否有NaN值
        nan= isnan(YTest(ii, :));
        % % 删除第一组数据中含有NaN的列
        Ydata_ii=YTest(ii,:);
        Ypre_ii=YPred(ii,:);
        Ydata_ii(:, nan) = [];
        Ypre_ii(:, nan) = [];
        % reference_without_nan = YPred(:, ~nan_columns);
        %         % 计算KGE
        %         KGE(ii,1) = objective_estimate_all(2,Ydata_ii,Ypre_ii);
    else
        Ydata_ii=YTest(ii,:);
        Ypre_ii=YPred(ii,:);
        %         % 没有NaN值的情况下直接计算KGE
        %         KGE(ii,1) = objective_estimate_all(2,YTest(ii,:),YPred(ii,:));
    end
    KGE(ii,1) = objective_estimate_all(2,Ydata_ii,Ypre_ii);
    R2(ii,1) = objective_estimate_all(3,Ydata_ii,Ypre_ii);
    RMSE(ii,1) = objective_estimate_all(4,Ydata_ii,Ypre_ii);
    NSE(ii,1) = objective_estimate_all(1,Ydata_ii,Ypre_ii);
    MAE(ii,1) = objective_estimate_all(5,Ydata_ii,Ypre_ii);
    Gama(ii,1) = objective_estimate_all(6,Ydata_ii,Ypre_ii);
    Beta(ii,1) = objective_estimate_all(7,Ydata_ii,Ypre_ii);
    Classfication(ii,1) = objective_estimate_all(9,Ydata_ii,Ypre_ii);
    CC(ii,1)=corr(Ydata_ii',Ypre_ii');
end


Kfold_accuracy.KGE=KGE;
Kfold_accuracy.R2=R2;
Kfold_accuracy.RMSE=RMSE;
Kfold_accuracy.NSE=NSE;
Kfold_accuracy.MAE=MAE;
Kfold_accuracy.Gama=Gama;
Kfold_accuracy.Beta=Beta;
Kfold_accuracy.Classfication=Classfication;
Kfold_accuracy.CC=CC;
