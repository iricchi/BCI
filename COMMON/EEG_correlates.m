%% Cleaning
close all
clear all
clc
%% Choose subject and spatial filter --> {'Mike','Flavio','Ilaria','Anon','Average','IlariaRH'}
subject = 'Anon';
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
disp('------------------------------------------------------')
disp('Filtering the signal and generating the PSD structure')
disp('------------------------------------------------------')
psdGenerator
disp('------------------------------------------------------')
disp('PSD generation completed')
disp('------------------------------------------------------')


%% Topoplot
disp('------------------------------------------------------')
disp('Generating topoplots')
disp('------------------------------------------------------')
TopoPlot
disp('------------------------------------------------------')
disp('Topoplots available')
disp('------------------------------------------------------')
%% Spectrograms
disp('------------------------------------------------------')
disp('Generating spectrograms')
disp('------------------------------------------------------')
SpectroGram
disp('------------------------------------------------------')
disp('Spectrograms available')
disp('------------------------------------------------------')
