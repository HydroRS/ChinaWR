clc; clear;

excel_file = 'XX.xlsx'; 
data_table = xlsread(excel_file);
[DataLength, num_vars] = size(data_table);
Iteration = 100; 
numVar = 13; 
VarImportance_Itation = zeros(Iteration, numVar); 
nTrees = 500;
leaf = 5;
fboot = 1;
surrogate = 'off';
metric = 'mse'; 
n_permutations = 10; 

for ii = 1:100
    Sample = datasample([1:DataLength]', ceil(0.8*DataLength), 'Replace', true);
    tempX = data_table(:, 3:end-1);
    tempY = data_table(:, end);


    RFModel = TreeBagger(nTrees, tempX, tempY, 'Method', 'regression', 'oobvarimp', 'on', 'surrogate', surrogate, 'minleaf', leaf, 'FBoot', fboot);

    nan_indices = isnan(tempY);
    X_cleaned = tempX(~nan_indices, :);
    y_cleaned = tempY(~nan_indices);


    importance = permutation_importance(RFModel, X_cleaned, y_cleaned, metric, n_permutations);
    VarImportance_Itation(ii, :) = importance;

    disp([num2str(ii), ' Iteration end']);
end


writematrix(VarImportance_Itation, 'XX.xlsx');


col_name = {'Max', 'Min', 'Mean'};
VarMaxMinMedian = zeros(numVar, length(col_name));

for kk = 1:numVar
    tempMax = max(VarImportance_Itation(:, kk));
    tempMin = min(VarImportance_Itation(:, kk));
    tempMedian = mean(VarImportance_Itation(:, kk));
    VarMaxMinMedian(kk, :) = [tempMax, tempMin, tempMedian];
end


Coltable = array2table(VarMaxMinMedian, 'VariableNames', col_name); 
writetable(Coltable, 'XX.xlsx', 'Sheet', 2);
