function importance = permutation_importance(model, X, y, metric, n_permutations)
    % 计算变量的permutation importance
    %
    % 参数：
    % model: 已经训练好的模型，例如treebagger
    % X: 特征数据，每行代表一个样本，每列代表一个特征
    % y: 目标数据，每行对应X中的一个样本
    % metric: 评估指标，例如'mse'
    % n_permutations: 进行的permutations次数
    
    % 预测原始数据的结果
    y_pred_orig = predict(model, X);
    
     % 计算原始MSE
    orig_mse = mean((y_pred_orig - y).^2);
    
    % 初始化permutation importance
    n_features = size(X, 2);
    importance = zeros(n_features,1);
    
    % 循环每个特征
    parfor i = 1:n_features
        
        % 初始化累计的metric差值
        metric_diff_sum = 0;
        
        % 复制原始特征数据
        X_permuted = X;
        
        % 对当前特征进行n_permutations次随机置换
        for j = 1:n_permutations
           % j
            % 随机置换当前特征的顺序
            X_permuted(:, i) = X(randperm(size(X, 1)), i);
            
            % 预测置换后的数据结果
            y_pred_permuted = predict(model, X_permuted);
            
            % 计算置换后的metric值
            switch metric
                case 'mse'
                    permuted_metric = mean((y_pred_permuted - y).^2);
                otherwise
                    error('Unknown metric. Please choose ''mse''.');
            end
            
            % 计算metric的差值并累加
            metric_diff_sum = metric_diff_sum + (permuted_metric-orig_mse); % incrase in MSE
        end
        
        % 计算平均metric差值
        importance(i) = metric_diff_sum / n_permutations;
    end
end
