function importance = permutation_importance(model, X, y, metric, n_permutations)
    % ���������permutation importance
    %
    % ������
    % model: �Ѿ�ѵ���õ�ģ�ͣ�����treebagger
    % X: �������ݣ�ÿ�д���һ��������ÿ�д���һ������
    % y: Ŀ�����ݣ�ÿ�ж�ӦX�е�һ������
    % metric: ����ָ�꣬����'mse'
    % n_permutations: ���е�permutations����
    
    % Ԥ��ԭʼ���ݵĽ��
    y_pred_orig = predict(model, X);
    
     % ����ԭʼMSE
    orig_mse = mean((y_pred_orig - y).^2);
    
    % ��ʼ��permutation importance
    n_features = size(X, 2);
    importance = zeros(n_features,1);
    
    % ѭ��ÿ������
    parfor i = 1:n_features
        
        % ��ʼ���ۼƵ�metric��ֵ
        metric_diff_sum = 0;
        
        % ����ԭʼ��������
        X_permuted = X;
        
        % �Ե�ǰ��������n_permutations������û�
        for j = 1:n_permutations
           % j
            % ����û���ǰ������˳��
            X_permuted(:, i) = X(randperm(size(X, 1)), i);
            
            % Ԥ���û�������ݽ��
            y_pred_permuted = predict(model, X_permuted);
            
            % �����û����metricֵ
            switch metric
                case 'mse'
                    permuted_metric = mean((y_pred_permuted - y).^2);
                otherwise
                    error('Unknown metric. Please choose ''mse''.');
            end
            
            % ����metric�Ĳ�ֵ���ۼ�
            metric_diff_sum = metric_diff_sum + (permuted_metric-orig_mse); % incrase in MSE
        end
        
        % ����ƽ��metric��ֵ
        importance(i) = metric_diff_sum / n_permutations;
    end
end
