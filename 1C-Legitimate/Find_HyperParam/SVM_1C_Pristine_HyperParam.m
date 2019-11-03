
clc
clear
close all

tic

% Add LIBSVM package
addpath(genpath('./Libsvm-3.17'));

% load the features already computed
load('Vchannel_features_H0_H1.mat');

%----------------------------------------------------------------------------------%
%                         Load features H0 and H1
%----------------------------------------------------------------------------------%


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

Ntest_S = 1000;       

tr_idx_S = 1001:6000;

te_idx_S = 1:1000;


%----------------------------------------------------------------------
%                     Initialize Train and Test Features
%----------------------------------------------------------------------

trainLabel = [ones(1,numel(tr_idx_S))]';
trainData = [data_H0_matrix(tr_idx_S,:)];

testLabel = [ones(1,Ntest_S)]';
testData = [data_H0_matrix(te_idx_S,:)];

testLabel1 = [-1*ones(1,Ntest_S)]';
testData1 = [data_H1_matrix(te_idx_S,:)];

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
%             Grid Search nu
%-------------------------------------------
pp=-10:1:0;
% if pp==0
%     nu(end) = nu(end-1);
% end
[RowPP,ColPP]=size(pp);
ColPP=ColPP-1;
for iii=1:ColPP
nuu(iii)=power(2,pp(iii));
end
[RowNU,ColNU]=size(nuu);
%--------------------------------------------
%            Best Gamma and nu
%--------------------------------------------
acc=zeros(Colg,ColNU);
acc1=zeros(Colg,ColNU);

for i=1:Colg
     g=gg(i);
     g
       for j=1:ColNU
           nu=nuu(j);
           nu
           
 model(i,j) = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(g) ' -n ' num2str(nu) ]); %positive
[~, accuracy, ~] = svmpredict(testLabel, testData, model(i,j), ' -b 0'); %negative
 [~, accuracy1,~] = svmpredict(testLabel1, testData1, model(i,j), ' -b 0'); %negative
 
 sprintf('gamma in for loop is %.5f',g)
 sprintf('nu in for loop is %.5f',nu)
 
 
 acc(i,j)=accuracy(1);
   sprintf('accuracy for testing legitimate from Legitimate in for loop is %.5f',acc(i,j))
 acc1(i,j)=accuracy1(1);
   sprintf('accuracy for testing Malicious from Legitimate in for loop is %.5f',acc1(i,j))

 
clear model
clear accuracy
clear accuracy1
close all
      
       end
    clc
end
 
close all
%----------------------------------

alpha=0.2;
beta=0.8;
final_acc=(alpha*acc)+(beta*acc1);

[value,location]=max(final_acc(:));
[Row,Col]=ind2sub(size(final_acc),location);

Gamma=gg(Row);
NU=nuu(Col);

sprintf('In case of alpha 0.3 beta 0.7 \n the max number is %.4f \n location in matrix is %d \n Rows is %4d \n columns is %d \n Gamma is %4d \n NU is %4d \n' ,value,location,Row,Col,Gamma,NU)

%---------------------------------
%   Scatter Plot Validation
%---------------------------------
model_Val = svmtrain(trainLabel, trainData, ['-s 2 -t 2 -b 0' ' -g ' num2str(Gamma) ' -n ' num2str(NU) ]);
[~,~, decision_positive_LEG_Val] = svmpredict(testLabel, testData, model_Val, ' -b 0'); %negative
[~,~ ,decision_negative_LEG_Val] = svmpredict(testLabel1, testData1, model_Val, ' -b 0');

figure(),
scatter(1:1000,decision_positive_LEG_Val,'d');xlabel('Samples Counts'); ylabel('Decision Function');
hold on
scatter(1:1000,decision_negative_LEG_Val,'+')
legend('legitimate (+)','Malacious (-)');
title(sprintf('Validation Scatter Plot (Vchannel,one class Leg)'));

save(['Results_Legitimate.mat'],'acc','acc1',...
      'alpha','beta','final_acc','Gamma','NU',...
      'decision_positive_LEG_Val','decision_negative_LEG_Val');


