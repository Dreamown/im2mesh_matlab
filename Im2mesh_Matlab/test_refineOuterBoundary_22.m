%%
clear all
clc

%%
addpath(genpath('mesh2d-master'))

%%
im = imread('kumamon.tif');

opt = [];                       % reset opt
opt.tolerance = 1;
opt.tf_mesh = false;            % do not generate mesh
bounds = im2mesh( im, opt );

% plotBounds(bounds,false,'ko-')

%%
targetSpace = 5;
bounds = refineOuterBoundary( bounds, targetSpace );

plotBounds(bounds,false,'ko-')



















