function [sum_traindata,sum_trainy,sum_test] = extract_process(WaterRR_Data,liuyu_idx,SubregionCelltrain,SubregionCelltest,kk)
start_day=2000;
end_day=2020;
sum_traindata=[];
sum_trainy=[];
sum_test=[];
Train_indices=SubregionCelltrain{kk};
Test_indices=SubregionCelltest{kk};
for year=start_day:end_day
    DataIndices=find(liuyu_idx(:,2)==year);%找到第一年的索引
    Data=WaterRR_Data(DataIndices,:); %找第一年索引的数据

    TrainData=Data(Train_indices,3:end-1);
    TrainY=Data(Train_indices,end);    %训练集的真实Y
    TestData=Data(Test_indices,3:end-1);
    sum_traindata=[sum_traindata;TrainData];
    sum_trainy=[sum_trainy;TrainY];
    sum_test=[sum_test;TestData];

end
%% RF

