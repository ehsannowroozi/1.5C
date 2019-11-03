
clc
clear
close all

tic

% Add LIBSVM package
addpath(genpath('./Libsvm-3.17'));

% load the features already computed
load('Vchannel_features_H0_H1.mat');
load('Results_Malicious.mat','Gamma','NU')  %Load Hyper Parameter

Gamma
NU

%-------------------------------------------------------------------------%
%                       Load the Features H0 and H1
%-------------------------------------------------------------------------%


data_H0_matrix = zeros(size(H0.features,2),numel(H0.features{1,1}));
data_H1_matrix = zeros(size(H1.features,2),numel(H1.features{1,1}));

for i=1:size(H0.features,2)
    data_H0_matrix(i,:) = H0.features{1,i};
end

for i=1:size(H1.features,2)
    data_H1_matrix(i,:) = H1.features{1,i};   
end

%----------------------------------------------------------------------
% 0. Define the setup and prepare data
%----------------------------------------------------------------------

Ntest_S = 1997;

tr_idx_S = 1001:6000;

te_idx_S = 6001:7997;


%----------------------------------------------------------------------
% 2. Training model using best_C and best_gamma
%----------------------------------------------------------------------

% Training on images from each class not used in cross-validation
trainLabel = [ones(1,numel(tr_idx_S))]';
trainData = [data_H1_matrix(tr_idx_S,:)];

% Train 

model_1C_Mal_Vchannel = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(Gamma) ' -n ' num2str(NU) ]); %alpha > beta

%--------------------------------------------------------------------------
%                                     Testing
%--------------------------------------------------------------------------

testLabel = [ones(1,Ntest_S)]';
testData = [data_H1_matrix(te_idx_S,:)];

testLabel1 = [-1*ones(1,Ntest_S)]';
testData1 = [data_H0_matrix(te_idx_S,:)];

% Test
[predict_label_positive, accuracy_positive, decision_positive_MAL] = svmpredict(testLabel, testData, model_1C_Mal_Vchannel, ' -b 0'); %positive

[predict_label_negative, accuracy_negative, decision_negative_MAL] = svmpredict(testLabel1, testData1, model_1C_Mal_Vchannel, ' -b 0'); %positive


Error_Probability_positive = 1- (accuracy_positive(1)/100);
Error_Probability_negative = 1- (accuracy_negative(1)/100);
MSE_positive=accuracy_positive(2);
MSE_negative=accuracy_negative(2);

%----------------------------------------------------------------
%                       Scatter Plot
%----------------------------------------------------------------
figure(),
scatter(1:1997,decision_positive_MAL,'d');xlabel('Samples Counts'); ylabel('Decision Function');
hold on
scatter(1:1997,decision_negative_MAL,'+');
legend('Malicious (+)','Legitimate (-)');
title(sprintf('Test Mal (Vchannel,one class) \n accuracy of testting in positive part (H1) is %.3f \n accuracy of testing in negative part (H0) is %.3f',accuracy_positive(1),accuracy_negative(1)));

%----------------------------------------------------------------
%         True Positive and False Positive and AUC
%----------------------------------------------------------------

% Roc Curve
AUC=0;

min=min(decision_negative_MAL);
max=max(decision_positive_MAL);
stepS=linspace(min,max,100);

 K=1;
 TP = zeros(K,numel(stepS));
 FP = zeros(K,numel(stepS));
 
 pe = decision_positive_MAL(:,:);
 pe1= decision_negative_MAL(:,:);
     

 for t=1:numel(stepS)

        TP(t) = sum(pe1<stepS(t))/1997;
        FP(t) = sum(pe<stepS(t))/1997;
     
 end
 
  AUC = abs(trapz(FP,TP));
 
 figure(),plot(FP,TP,'*-');xlabel('False Positive'); ylabel('True Negative');title(sprintf('AUC: %.2f',abs(trapz(FP,TP))));
 
 
 title(sprintf('Test Roc Curve (Vchannel-Malicious) \n AUC : %.4f',AUC));

 
%---------------------------------------------------------------------
%                       Save The Results
%---------------------------------------------------------------------

save(['Results_AWARE_1C_Mal.mat'],'model_1C_Mal_Vchannel','testLabel','testData','H0','H1','data_H0_matrix','data_H1_matrix', ...
     'TP','FP','predict_label_positive', 'accuracy_positive', 'decision_positive_MAL', ...
     'predict_label_negative', 'accuracy_negative', 'decision_negative_MAL',...
     'Ntest_S','tr_idx_S', 'te_idx_S','AUC','AUC1Percent');
 
 decision_function_MAL = [decision_negative_MAL ; decision_positive_MAL];
 
 decision_function_MAL_Vchannel=decision_function_MAL;
 save('decision_function_MAL_Vchannel')
 save('model_1C_Mal_Vchannel')
