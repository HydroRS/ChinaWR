function [ output ] = objective_estimate_all( ObjType, Obs_vec, simu_vec)
%UNTITLED4 Summary of this function goes here
%   （真实，预测）
Obs_vec=Obs_vec';
simu_vec=simu_vec';

if ObjType ==1 % NSE
    NSE=1-(sum((Obs_vec-simu_vec).^2)/sum(Obs_vec-mean(Obs_vec).^2));
    output=NSE;
    str_type='NSE';
elseif ObjType ==2 % KGE'
    r=corr(simu_vec,Obs_vec);   % CC
    r_val=(r-1)^2;
    
    gama=(std(simu_vec)/mean(simu_vec))/(std(Obs_vec)/mean(Obs_vec));
    std_val=(gama-1)^2;
    
    beta=mean(simu_vec)/mean(Obs_vec); % 偏差率
    u_val=(beta-1)^2;
    KGE=1-sqrt(r_val+std_val+u_val);
    %      output=[KGE,r,beta,gama];  % 还是返回一个数字
    output = KGE;
    str_type='KEG';
elseif ObjType ==3 % R2
    CC=corr(simu_vec,Obs_vec)^2;
    output=CC;
    str_type='R2';
elseif ObjType==4 % RMSE
    RMSE=sqrt((sum((simu_vec-Obs_vec).^2))/length(Obs_vec));
    output=RMSE;
    str_type='RMSE';
elseif ObjType==5 % MAE
     MAE=mean(abs(Obs_vec - simu_vec)); 
     output=MAE;
     str_type='MAE';
elseif ObjType==6 % Game
    gama=(std(simu_vec)/mean(simu_vec))/(std(Obs_vec)/mean(Obs_vec));
    output=gama;
elseif ObjType==7 % Beta
    beta=mean(simu_vec)/mean(Obs_vec); % 偏差率
    output=beta;
elseif ObjType==9 % Classfication
    temp_simu=simu_vec;
    temp_simu(temp_simu>0)=1;
    temp_obs=Obs_vec;
    temp_obs(temp_obs>0)=1;
    TP=length(find((temp_obs-temp_simu)==0));
    calssfication_rata=TP/length(temp_obs); %分类准确率
    output=calssfication_rata;    
end

end

