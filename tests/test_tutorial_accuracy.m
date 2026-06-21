function test_tutorial_accuracy()
% End-to-end sanity: wavelet-transform features plus a pseudo-inverse solve must
% beat raw pixels and clear a low bar on the bundled textures. This guards the
% whole pipeline, not an exact number.
  d = load('tutorial/data/textures_small.mat');
  Xtr = double(d.Xtrain) / 255; Xte = double(d.Xtest) / 255;
  Ftr = scatter_features(Xtr, 3, 4);
  Fte = scatter_features(Xte, 3, 4);
  m = pinv_classify('fit', Ftr, d.ytrain, 1e-2);
  acc = mean(pinv_classify('predict', m, Fte) == d.ytest);

  Rtr = reshape(Xtr, size(Xtr, 1) * size(Xtr, 2), []).';
  Rte = reshape(Xte, size(Xte, 1) * size(Xte, 2), []).';
  mr = pinv_classify('fit', Rtr, d.ytrain, 1e-2);
  acc_raw = mean(pinv_classify('predict', mr, Rte) == d.ytest);

  fprintf('wavelet acc = %.3f, raw acc = %.3f\n', acc, acc_raw);
  assert(acc > 0.6, 'wavelet-transform accuracy unexpectedly low');
  assert(acc > acc_raw, 'wavelet-transform features should beat raw pixels');
end
