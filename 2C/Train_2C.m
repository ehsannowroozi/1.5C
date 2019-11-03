
%-------------------------------------------------------------------------
%                               IMPORTANT
%
% This code refer to the 2C classifier therefore change the numbers based
% on your applications such as how many images you want to consider for
% traning, validation and testing.
%-------------------------------------------------------------------------

clc
clear
close all

tic

% Add LIBSVM package
addpath(genpath('./Libsvm-3.17'));

% load the features already computed
load('Vchannel_features_H0_H1.mat');

%-------------------------------------------------------------------------%
%                      1)  Initialize the features
%-------------------------------------------------------------------------%

Proc_Type1  = '2C';

data_H0_matrix = zeros(size(H0.features,2),numel(H0.features{1,1}));
data_H1_matrix = zeros(size(H1.features,2),numel(H1.features{1,1}));


for i=1:size(H0.features,2)
    data_H0_matrix(i,:) = H0.features{1,i};
end

for i=1:size(H1.features,2)
    data_H1_matrix(i,:) = H1.features{1,i};
end


%----------------------------------------------------------------------
%                    2) Define the setup and prepare data
%----------------------------------------------------------------------

% These number depends how many images you want to use for traning,
% validation and testing therefore change this number to your setup.
% CV = Cross validation, tr = Traning, and te = Testing

 
Ntest_H0 = 1997;
Ntest_H1 = Ntest_H0;

cv_idx_H0 = 1:1000;      %1000 for cross validation
cv_idx_H1 = cv_idx_H0;
tr_idx_H0 = 1001:6000;   %5000 for training
tr_idx_H1 = tr_idx_H0;
te_idx_H0 = 6001:7997;   %1997 for testing
te_idx_H1 = te_idx_H0;

%----------------------------------------------------------------------
%                       3) N-fold cross-validation
%----------------------------------------------------------------------

cross_labels = [ones(1,numel(cv_idx_H0)), -1*ones(1,numel(cv_idx_H1))]';

% Examples for cross-validation
cross_data = [data_H0_matrix(cv_idx_H0,:); data_H1_matrix(cv_idx_H1,:)];

% Grid of parameters
folds = 5;
[C,gamma] = meshgrid(-5:2:15, -15:2:3);

% Grid search
cv_acc = zeros(numel(C),1);
for i=1:numel(C)
    cv_acc(i) = svmtrain(cross_labels, cross_data, ...
        sprintf('-q -c %f -g %f -v %d', 2^C(i), 2^gamma(i), folds));
end

% Pair (C,gamma) with best accuracy
[~,idx] = max(cv_acc);

%----------------------------------------------------------------------
%             4) Training model with best_C and best_gamma
%----------------------------------------------------------------------

bestc = 2^C(idx);
bestg = 2^gamma(idx);

% Training on images from each class not used in cross-validation
trainLabel = [ones(1,numel(tr_idx_H0)), -1*ones(1,numel(tr_idx_H1))]';
trainData = [data_H0_matrix(tr_idx_H0,:); data_H1_matrix(tr_idx_H1,:)];

% Train (For probabilistic model  change to b1 and for decesion function chane to b0)
% Note: Libsvm one-class classification does not support the probabilistic
% model therefore its better to use b0
model_2C_Vchannel = svmtrain(trainLabel, trainData, ['-c ' num2str(bestc) ' -g ' num2str(bestg) ' -b 0']);

%--------------------------------------------------------------------------
%                                     Testing
%--------------------------------------------------------------------------

testLabel = [ones(1,Ntest_H0), -1*ones(1,Ntest_H1)]';
testData = [data_H0_matrix(te_idx_H0,:); data_H1_matrix(te_idx_H1,:)];

% Test
[predict_label, accuracy, decision_function_LM] = svmpredict(testLabel, testData, model_2C_Vchannel, ' -b 0');

%--------------------------------------------------------------------------
%                   True Positive and False Positive and AUC
%--------------------------------------------------------------------------

%%%%%%
Accuracy_Test = accuracy(1);
MSE_Test = accuracy(2);
Error_Probability = 1-(accuracy(1)/100);
sprintf('Accuracy in testing part is: %f ',Accuracy_Test)
sprintf('Mean Square Error in testing part is: %f ',MSE_Test)
sprintf('Error Probability in testing part is: %f ',Error_Probability)
%%%%%%
 
%Scatter PLot for Leg
figure;
scatter(1:1997,decision_function_LM(1:1997,:)); xlabel('Samples'); ylabel('Decision Function');
hold on
%Scatter PLot for Mal
scatter(1:1997,decision_function_LM(1998:3994,:)); xlabel('Samples'); ylabel('Decision Function'); 
legend('legitimate','Malicious');
% line
x=[0 1997];
y=[0 0];
plot(x,y)

title(sprintf('Two-Class-Classification,\n Accuracy of test, MSE, Error Probability are respectivly,\n %.4f %.4f %.4f ',Accuracy_Test,MSE_Test, Error_Probability));


% -------------------------------------------------------------------------
%                    Auc and Roc Curve
% -------------------------------------------------------------------------

AUC=0;
min=min(decision_function_LM(1998:3994,:));
max=max(decision_function_LM(1:1997,:));
stepS=linspace(min,max,100);

 K=1;
 TP = zeros(K,numel(stepS));
 FP = zeros(K,numel(stepS));
 
     pe = decision_function_LM(1:1997,:);
     pe1 = decision_function_LM(1998:3994,:);
     
 for t=1:numel(stepS)
     TP(t) = sum(pe1<stepS(t))/1997;
     FP(t) = sum(pe<=stepS(t))/1997;
 end
 
  AUC = abs(trapz(FP,TP));
 
 figure(),plot(FP,TP,'*-');xlabel('False Positive'); ylabel('True Negative');title(sprintf('AUC: %.2f',abs(trapz(FP,TP))));

% % % %---------------------------------------------------------------------
% % % %                       Save The Results
% % % %---------------------------------------------------------------------

save(['Result_' Proc_Type1 '.mat'],'model_2C_Vchannel','H0','H1', 'data_H0_matrix', ...
    'data_H1_matrix', 'decision_function_LM','accuracy','Error_Probability','predict_label','AUC','TP','FP', ...
    'Ntest_H0','Ntest_H1', 'cv_idx_H0', 'cv_idx_H1', 'tr_idx_H0', 'tr_idx_H1', 'te_idx_H0', 'te_idx_H1','C','gamma','cv_acc')
decision_function_LM_Vchannel=decision_function_LM;
save('decision_function_LM_Vchannel')
save('model_2C_Vchannel')
% % % 
% % % 
t=toc;
fprintf('Elapsed Time: %.3f sec.\n',t);