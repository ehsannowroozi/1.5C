
clc
clear
close all

tic

% Add LIBSVM package
addpath(genpath('./Libsvm-3.17'));

% Load the features already computed (d1, d2 and d3) or decisions 
load('decision_function_LM_Vchannel.mat','decision_function_LM_Vchannel');
load('decision_function_LEG_Vchannel.mat','decision_function_LEG_Vchannel');
load('decision_function_MAL_Vchannel.mat','decision_function_MAL_Vchannel');

load('Results_Legitimate.mat','Gamma','NU') % Load hyper parameters
Gamma
NU

Combine_Matrix_Classifiers_Vchannel = [decision_function_LM_Vchannel,...
                                       decision_function_LEG_Vchannel,...
                                       decision_function_MAL_Vchannel]; 
                                   
Combine_Matrix_H0 = Combine_Matrix_Classifiers_Vchannel(1:1997,:);
Combine_Matrix_H1 = Combine_Matrix_Classifiers_Vchannel(1998:3994,:);
%----------------------------------------------------------------------
% 0. Define the setup and prepare data
%----------------------------------------------------------------------

Ntest_S = 997;

tr_idx_S = 301:1000 ; 

te_idx_S = 1001:1997 ; 

%----------------------------------------------------------------------
%                           Training
%----------------------------------------------------------------------

trainLabel = [ones(1,numel(tr_idx_S))]';     %3000 labels one
trainData = [Combine_Matrix_H0(tr_idx_S,:)]; %3000 trainData

% Train 
model_Combine_Vchannel = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(Gamma) ' -n ' num2str(NU) ]); 

%--------------------------------------------------------------------------
%                                     Testing
%--------------------------------------------------------------------------

testLabel = [ones(1,Ntest_S)]'; 
testData = [Combine_Matrix_H0(te_idx_S,:)]; % 997 member
 
testLabel1 = [-1*ones(1,Ntest_S)]'; 
testData1 = [Combine_Matrix_H1(te_idx_S,:)]; % 997 member

% Test
[predict_label_positive, accuracy_LEG, decision_LEG] = svmpredict(testLabel, testData, model_Combine_Vchannel, ' -b 0'); %positive  %1997

[predict_label_negative, accuracy_MAL, decision_MAL] = svmpredict(testLabel1, testData1, model_Combine_Vchannel, ' -b 0'); %negative %1997


Error_Probability_LEG = 1- (accuracy_LEG(1)/100);
Error_Probability_MAL = 1- (accuracy_MAL(1)/100);
MSE_LEG=accuracy_LEG(2);
MSE_MAL=accuracy_MAL(2);

%----------------------------------------------------------------
%         True Positive and False Positive and AUC
%----------------------------------------------------------------

% Roc Curve
AUC=0;

min=min(decision_MAL);
max=max(decision_LEG);
stepS=linspace(min,max,100);

 K=1;
 TP = zeros(K,numel(stepS));
 FP = zeros(K,numel(stepS));
 
 TP1 = zeros(K,numel(stepS));
 FP1 = zeros(K,numel(stepS));
 
     pe = decision_LEG(:,:);
     pe1= decision_MAL(:,:);
    

 for t=1:numel(stepS)
     
      TP(t) = sum(pe1<stepS(t))/997;
      FP(t) = sum(pe<stepS(t))/997;
     
 end
 
  AUC = abs(trapz(FP,TP));
 
 figure(),plot(FP,TP,'*-');xlabel('False Positive'); ylabel('True Negative');title(sprintf('AUC: %.2f',abs(trapz(FP,TP))));
 
 title(sprintf('Classifiers Combination (One-Class-Leg, Vchannel, TIFF) \n AUC : %.4f',AUC));

 
%---------------------------------------------------------------------
%                       Scatter Plot of Combination
%---------------------------------------------------------------------
figure,
scatter(1:997,decision_LEG,'d');xlabel('Sample Count'); ylabel('Decision Function');
hold on
scatter(1:997,decision_MAL,'+')
legend('Decision _ legitimate (+)','Decision _ Malicious (-)','Location','southeast');
title(sprintf('Decision Function in case of Legitimate and Malacious \n (Classifiers combination) \n Accuracy of Legitimate is %.3f \n Accuracy of Malicious is %.3f',accuracy_LEG(1),accuracy_MAL(1)));
 
%---------------------------------------------------------------------
%                       Save The Results
%---------------------------------------------------------------------

save(['Classifiers_Combination_Vchannel.mat'],'Combine_Matrix_Classifiers_Vchannel','trainLabel','trainData',...
    'testLabel','testData',...
    'testLabel1','testData1',...
     'model_Combine_Vchannel', 'TP','FP','decision_LEG','decision_MAL','AUC','AUC1Percent');
 save(['Classifiers_Combination_LEG_MAL.mat'],'decision_LEG','decision_MAL');
 save('model_Combine_Vchannel')

