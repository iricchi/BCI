clear all
close all
clc
%% Choose Person --> {'Mike','Flavio','Ilaria','Anon'}
subject = 'Flavio';

%% Loading functions
parent_folder = fileparts(pwd);

addpath(genpath([parent_folder, '\biosig']));
addpath(genpath([parent_folder, '\eeglab_current']));
addpath(genpath([parent_folder, '\eeglab13_4_4b']));

load([parent_folder, '\VariousData','\channel_location_16_10-20_mi.mat']);
load([parent_folder, '\VariousData','\laplacian_16_10-20_mi.mat']);
%% Loading signals
[ offline_names, online_names ] = extractOffOnLineFileNames( subject , parent_folder);

%% Extracting signals from files

