function compare_approaches()
% COMPARE_APPROACHES  One-glance comparison of the three representations.
%
% Runs all three on the same bundled textures with the same pseudo-inverse
% readout (no training) and prints the accuracy side by side:
%   raw pixels  ->  first-order wavelet scattering  ->  second-order scattering
%
% It takes the shared core from common/, the first-order features from tutorial/,
% and the second-order features from matlab/, so it sits above the two tiers and
% does not make either one depend on the other. It is light: the whole run is a
% few seconds. Run it from the repo root:  compare_approaches
  addpath('common'); addpath('tutorial'); addpath('matlab');

  d = load('tutorial/data/textures_small.mat');
  Xtrain = double(d.Xtrain) / 255; Xtest = double(d.Xtest) / 255;
  ytrain = d.ytrain; ytest = d.ytest;

  % Raw pixels: flatten the image, no wavelet step at all.
  Rtr = reshape(Xtrain, size(Xtrain, 1) * size(Xtrain, 2), []).';
  Rte = reshape(Xtest,  size(Xtest, 1) * size(Xtest, 2), []).';
  acc_raw = accuracy(Rtr, Rte, ytrain, ytest);

  % First-order wavelet scattering: the tutorial features (3 levels, pooled).
  F1tr = scatter_features(Xtrain, 3, 4); F1te = scatter_features(Xtest, 3, 4);
  acc1 = accuracy(F1tr, F1te, ytrain, ytest);

  % Second-order wavelet scattering: the advanced features (4 levels, deeper).
  F2tr = wscat.features(Xtrain); F2te = wscat.features(Xtest);
  acc2 = accuracy(F2tr, F2te, ytrain, ytest);

  fprintf('\nSame textures, same pseudo-inverse readout, no training:\n');
  fprintf('  raw pixels             %5.1f%%\n', 100 * acc_raw);
  fprintf('  first-order wavelet    %5.1f%%\n', 100 * acc1);
  fprintf('  second-order wavelet   %5.1f%%\n', 100 * acc2);
  fprintf('\nMore wavelet structure means more accuracy, with no training step.\n');
end


function a = accuracy(Ftr, Fte, ytr, yte)
% Fit the pseudo-inverse classifier on the training features and score the test.
  model = pinv_classify('fit', Ftr, ytr, 1e-2);
  a = mean(pinv_classify('predict', model, Fte) == yte);
end
