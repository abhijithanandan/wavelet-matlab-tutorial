% WAVELET SCATTERING NETWORK: a hands-on tutorial in MATLAB
%
% This script shows how a convolutional network can classify textures using
% filters that are DESIGNED, not learned: the Haar wavelet transform written as
% plain filters, and a classifier solved in one step with no training. It is the
% non-iterative, pseudo-inverse version of the wavelet CNN idea.
%
% How to use it:
%   - To just run it: open this tutorial folder in MATLAB and type  run_tutorial
%   - To step through it as a notebook: in MATLAB, Save As a Live Script (.mlx).
%     The %% lines below become sections you can run one at a time.
%
% It needs no toolboxes (so it also runs in GNU Octave), no Python, and no
% downloads: the textures are bundled in data/textures_small.mat. Run it from
% inside this folder. Figures are saved as PNGs in figures/ and shown on screen
% when a display is available.

% The shared core (haar_dwt, pinv_classify) lives in the sibling common/ folder.
addpath('../common');

display_ok = true;
if exist('OCTAVE_VERSION', 'builtin'), display_ok = ~isempty(getenv('DISPLAY')); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Step 1: Load the textures
% A small set of grayscale textures, 64x64 pixels, six classes.
d = load('data/textures_small.mat');
Xtrain = double(d.Xtrain) / 255;
Xtest  = double(d.Xtest)  / 255;
ytrain = d.ytrain;
ytest  = d.ytest;
C = max(ytrain);
fprintf('Loaded %d training and %d test textures (64x64, %d classes).\n', ...
        size(Xtrain, 3), size(Xtest, 3), C);
show_save(montage_image(Xtrain(:, :, round(linspace(1, size(Xtrain,3), 12))), 6, 2), ...
          'example textures', 'figures/example_textures.png', display_ok);

%% Step 2: One level of the wavelet transform, and what it extracts
% The Haar wavelet splits an image into four half-size sub-bands: a blurred
% approximation (LL) and three detail bands (LH, HL, HH) that pick out
% horizontal, vertical, and diagonal edges. These are fixed filters, not learned.
img = Xtrain(:, :, 1);
[LL, LH, HL, HH] = haar_dwt(img);
bands = cat(3, LL, abs(LH), abs(HL), abs(HH));
show_save(montage_image(upscale(bands, 2), 4, 2), ...
          'wavelet sub-bands (LL, |LH|, |HL|, |HH|)', ...
          'figures/subbands.png', display_ok);

%% Step 3: The scattering cascade
% We do not stop at one level. We feed the LL approximation back into the same
% wavelet transform, three times, so the deeper "layers" take their input from
% the wavelet transform of the previous level. At each level we keep the modulus
% of the detail bands, pooled into a small grid, and at the end we also keep the
% final approximation. Stacking these gives one feature vector per image.
fprintf('Extracting scattering features for all textures ...\n');
t = tic;
Ftrain = scatter_features(Xtrain, 3, 4);
Ftest  = scatter_features(Xtest, 3, 4);
fprintf('Done in %.1f s. Each texture is now a %d-number feature vector.\n', ...
        toc(t), size(Ftrain, 2));

%% Step 4: Solve the classifier in one step, and test it
% No training: standardise the features, write the labels as one-hot columns, and
% solve one least-squares system with the pseudo-inverse. That single solve is
% the classifier.
model = pinv_classify('fit', Ftrain, ytrain, 1e-2);
pred  = pinv_classify('predict', model, Ftest);
acc = mean(pred == ytest);
fprintf('\nTest accuracy: %.2f%%  (no training, just one pseudo-inverse solve)\n', ...
        100 * acc);
conf = zeros(C, C);
for i = 1:numel(ytest), conf(ytest(i), pred(i)) = conf(ytest(i), pred(i)) + 1; end
fprintf('\nConfusion matrix (rows = true class, cols = predicted):\n');
for r = 1:C, fprintf('  %d:  %s\n', r, sprintf('%4d', conf(r, :))); end

%% Step 5: Do the wavelet features help?
% Same pseudo-inverse classifier, on the raw pixels versus on the scattering
% features.
Fraw_tr = reshape(Xtrain, size(Xtrain,1) * size(Xtrain,2), []).';
Fraw_te = reshape(Xtest,  size(Xtest,1) * size(Xtest,2), []).';
raw_model = pinv_classify('fit', Fraw_tr, ytrain, 1e-2);
acc_raw = mean(pinv_classify('predict', raw_model, Fraw_te) == ytest);
fprintf('\n[1] Do the wavelet features help? (same classifier, with vs without)\n');
fprintf('  raw pixels:          %.2f%%\n', 100 * acc_raw);
fprintf('  scattering features: %.2f%%\n', 100 * acc);
fprintf('  the wavelet features add about %.0f points.\n', 100 * (acc - acc_raw));

%% Step 6: Is the pseudo-inverse doing the work?
% The features are fixed (nothing in the network was trained). With RANDOM output
% weights the network is at chance. The pseudo-inverse solves the output layer in
% one closed-form step.
mu = mean(Ftrain, 1); sd = std(Ftrain, 0, 1); sd(sd == 0) = 1;
Zte = [(Ftest - mu) ./ sd, ones(size(Ftest, 1), 1)];
rand('seed', 1); rand_W = randn(size(Zte, 2), C);
[~, pred_rand] = max(Zte * rand_W, [], 2);
acc_rand = mean(pred_rand == ytest);
fprintf('\n[2] Is the pseudo-inverse doing the work? (same fixed features)\n');
fprintf('  random output weights (no solve):  %.2f%%\n', 100 * acc_rand);
fprintf('  pseudo-inverse output (one solve): %.2f%%\n', 100 * acc);

%% Step 7: Would training the classifier do better?
% Gradient descent on the same features reaches a bit higher, but only after many
% iterations. This is the accuracy traded away to skip training.
tr_model = softmax_classify('fit', Ftrain, ytrain);
acc_trained = mean(softmax_classify('predict', tr_model, Ftest) == ytest);
fprintf('\n[3] Would training do better? (same features, two ways to set the output)\n');
fprintf('  pseudo-inverse (one solve, no training): %.2f%%\n', 100 * acc);
fprintf('  trained by gradient descent (iterative): %.2f%%\n', 100 * acc_trained);

fprintf('\nDone. Figures saved in the figures/ folder.\n');
