% FULL WAVELET SCATTERING NETWORK (advanced reference)
%
% Runs the deeper, second-order scattering network on the bundled textures with
% a pseudo-inverse readout. Like the tutorial it uses no toolboxes and runs in
% GNU Octave. Run it from the matlab/ folder:  run_full_wscat
%
% The shared core (haar_dwt, pinv_classify) lives in the sibling common/ folder.
addpath('../common');

d = load('../tutorial/data/textures_small.mat');
Xtrain = double(d.Xtrain) / 255;
Xtest  = double(d.Xtest)  / 255;
ytrain = d.ytrain; ytest = d.ytest;

fprintf('Extracting second-order scattering features ...\n');
t = tic;
Ftrain = wscat.features(Xtrain);
Ftest  = wscat.features(Xtest);
fprintf('Done in %.1f s. Feature dimension: %d.\n', toc(t), size(Ftrain, 2));

model = pinv_classify('fit', Ftrain, ytrain, 1e-2);
acc = mean(pinv_classify('predict', model, Ftest) == ytest);
fprintf('Full wavelet scattering test accuracy: %.2f%%\n', 100 * acc);
