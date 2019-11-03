

clc
clear
close all

tic

% Add LIBSVM package
addpath(genpath('./Libsvm-3.17'));

load('decision_function_LM_Vchannel.mat','decision_function_LM_Vchannel');
load('decision_function_LEG_Vchannel.mat','decision_function_LEG_Vchannel');
load('decision_function_MAL_Vchannel.mat','decision_function_MAL_Vchannel');

Combine_Matrix_Classifiers_Vchannel = [decision_function_LM_Vchannel,decision_function_LEG_Vchannel,decision_function_MAL_Vchannel];
Combine_Matrix_H0 = Combine_Matrix_Classifiers_Vchannel(1:1997,:);
Combine_Matrix_H1 = Combine_Matrix_Classifiers_Vchannel(1998:3994,:);

% Combine_Matrix_H0=normVec(Combine_Matrix_H0,1);
% Combine_Matrix_H1=normVec(Combine_Matrix_H1,1);
%----------------------------------------------------------------------
% 0. Define the setup and prepare data
%----------------------------------------------------------------------

Ntest_S = 300;

tr_idx_S = 301:1000 ; %H0

te_idx_S = 1:300 ; %(Validation)


%----------------------------------------------------------------------
%                           TRAINING
%----------------------------------------------------------------------

trainLabel = [ones(1,numel(tr_idx_S))]'; % Only with H0
trainData = [Combine_Matrix_H0(tr_idx_S,:)];

%-----------------------------------------------------------------------
%                          validation
%-----------------------------------------------------------------------

testLabel = [ones(1,Ntest_S)]'; %select from decision function L
testData = [Combine_Matrix_H0(te_idx_S,:)];

testLabel1 = [-1*ones(1,Ntest_S)]'; %select from decision function M
testData1 = [Combine_Matrix_H1(te_idx_S,:)];

%-------------------------------------------
%             Grid Search Gamma
%-------------------------------------------
p=-10:1:10;
[RowP,ColP]=size(p);
for ii=1:ColP
gg(ii)=power(2,p(ii));
end
[Rowg,Colg]=size(gg);
%-------------------------------------------
%             Grid Search NU
%-------------------------------------------
pp=-10:1:0;
[RowPP,ColPP]=size(pp);
ColPP=ColPP-1;
for iii=1:ColPP
nuu(iii)=power(2,pp(iii));
end
[RowNU,ColNU]=size(nuu);
%--------------------------------------------
%            Best Gamma and NU
%--------------------------------------------
acc=zeros(Colg,ColNU);
acc1=zeros(Colg,ColNU);

for i=1:Colg
     g=gg(i);
     g
       for j=1:ColNU
           nu=nuu(j);
           nu
                
        
         model(i,j) = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(g) ' -n ' num2str(nu) ]);
        [~, accuracy, ~] = svmpredict(testLabel, testData, model(i,j), ' -b 0');
        [~, accuracy1, ~] = svmpredict(testLabel1, testData1, model(i,j), ' -b 0');
        
        sprintf('gamma in for loop is %.5f',g)
        sprintf('nu in for loop is %.5f',nu)
        
        acc(i,j)=accuracy(1);
        sprintf('accuracy acc %.5f',acc(i,j))
        acc1(i,j)=accuracy1(1);
        sprintf('accuracy acc1 %.5f',acc1(i,j))
        
        clear model
        clear accuracy
        clear accuracy1
        close all
        
    end
    clc
end

close all
%----------------------------------

alpha=0.1;
beta=0.9;
final_acc=(alpha*acc)+(beta*acc1);

[value,location]=max(final_acc(:));
[Row,Col]=ind2sub(size(final_acc),location);

Gamma=gg(Row);
NU=nuu(Col);

sprintf('In case of alpha 0.1 beta 0.9 \n the max number is %.4f \n location in matrix is %d \n Rows is %4d \n columns is %d \n Gamma is %4d \n NU is %4d \n' ,value,location,Row,Col,Gamma,NU)

%---------------------------------
%   Scatter Plot Validation
%---------------------------------
model_Val = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(Gamma) ' -n ' num2str(NU) ]);
[~,~, decision_LEG] = svmpredict(testLabel, testData, model_Val, ' -b 0'); %negative
[~,~ ,decision_MAL] = svmpredict(testLabel1, testData1, model_Val, ' -b 0');

figure(),
scatter(1:300,decision_LEG,'d');xlabel('Samples Counts'); ylabel('Decision Function');
hold on
scatter(1:300,decision_MAL,'+')
legend('Decision _ legitimate (+)','Decision _ Malicious (-)');
title(sprintf('Validation Scatter Plot (Vchannel,Combination Leg)'));
%---------------------------------
%         AUC Validation
%---------------------------------
AUC_Val=0;

min=min(decision_MAL);
max=max(decision_LEG);
stepS=linspace(min,max,100);

 K=1;
 TP = zeros(K,numel(stepS));
 FP = zeros(K,numel(stepS));
 
     pe = decision_LEG(:,:);
     pe1= decision_MAL(:,:);
    

 for t=1:numel(stepS)
      TP(t) = sum(pe>=stepS(t))/Ntest_S;
      FP(t) = sum(pe1>=stepS(t))/Ntest_S;
     
 end
 
  AUC_Val = abs(trapz(FP,TP));
  AUC_Val
 
 figure(),plot(FP,TP,'*-');xlabel('False Positive'); ylabel('True Positive');title(sprintf('Combination AUC (Validation) : %.4f',abs(trapz(FP,TP))));
%---------------------------------
%       AUC1Percent Validation
%---------------------------------
TP1 = zeros(K,numel(stepS));
FP1 = zeros(K,numel(stepS));

ii=0;
for tt=1:numel(stepS)
    if (FP(tt) <= 0.01) %you don't need to condition of TP
        ii = ii+1;
        FP1(ii)=FP(tt);
        TP1(ii)=TP(tt); 
    end
end

 AUC1Percent_Val = (abs(trapz(FP1,TP1)))/0.01;
 AUC1Percent_Val
 %------------------------------
save(['Results_Legitimate.mat'],'acc','acc1',...
      'alpha','beta','final_acc','Gamma','NU',...
      'AUC1Percent_Val','AUC_Val','decision_MAL','decision_LEG');




