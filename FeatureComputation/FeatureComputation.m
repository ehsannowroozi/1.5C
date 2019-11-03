
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The script
% 1. Call the H0 (pristine images)and H1 (manipualted imaegs) images. 
% 2. For each class of hypothesis features are extract from last layer of
% HSV. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

% Add a version of LIBSVM 3.22 package
addpath(genpath('./Libsvm-3.17'));

% Read the Path of H0 (pristine images) and H1 (manipualted images) 
H0 = '..........\H0\';
H1 = '..........\H1\';
%----------------------------------------------------------
%            Feature Computation SPAM686V.M
%----------------------------------------------------------

H0 = computeAllFeatures(H0);
H1 = computeAllFeatures(H1);


save('Vchannel_features_H0_H1.mat', 'H0', 'H1');



