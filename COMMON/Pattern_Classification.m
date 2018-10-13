%% Cleaning
close all
clear all
clc
%% Choose subject and spatial filter --> {'Mike','Flavio','Ilaria','Anon','Average','IlariaRH'}
subject = 'Mike';
sfilter = 'Lap' ; % CAR, Lap

%% Defining event types
global cueType

cueType.FIX = hex2dec('312');
cueType.CUEH = hex2dec('305');
cueType.CUEF = hex2dec('303');
cueType.CONT_FEED = hex2dec('30d');
cueType.FEED_H = hex2dec('30e');
cueType.FEED_F = hex2dec('30f');
cueType.BOOM_MISS = hex2dec('381');
cueType.BOOM_HIT = hex2dec('382');

%% Loading functions (if already in the matlab path, no need to do it)
parent_folder = fileparts(pwd);

addpath(genpath([parent_folder, '\biosig']));
addpath(genpath([parent_folder, '\eeglab_current']));
addpath(genpath([parent_folder, '\eeglab13_4_4b']));

load([parent_folder, '\VariousData','\channel_location_16_10-20_mi.mat']);
load([parent_folder, '\VariousData','\laplacian_16_10-20_mi.mat']);

%% PSD generation
disp('-----------------------------------------------------------------------')
disp('Filtering the signal and generating the PSD structure for all the runs')
disp('-----------------------------------------------------------------------')
psdGenerator
disp('------------------------------------------------------')
disp('PSD generation completed')
disp('------------------------------------------------------')

%% Feature selection
% It is needed to click on the features of interest in the 'Mean Values'
% plot in order to proceed. When done, press enter and the features will be
% saved.
disp('------------------------------------------------------')
disp('Generating discriminancy maps.')
disp('Please select the features of interest')
disp('------------------------------------------------------')
DiscriminancyMap
disp('------------------------------------------------------')
disp('Features saved')
disp('------------------------------------------------------')

%% Classifier and rolling CV
disp('------------------------------------------------------')
disp('Training, testing and validating the best classifier')
disp('------------------------------------------------------')
Classifier
disp('------------------------------------------------------')
disp('Classifier Completed')
disp('------------------------------------------------------')
%% Pseudonline run
disp('------------------------------------------------------')
disp('Running a pseudonline run')
disp('------------------------------------------------------')
PseudOnline
disp('------------------------------------------------------')
disp('Everything completed.')
disp('------------------------------------------------------')