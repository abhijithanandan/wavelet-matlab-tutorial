function test_pinv_classify()
% Two clearly separated clusters in 2-D must be classified perfectly.
  rand('seed', 0);
  A = [randn(20, 2) * 0.1 + 3];   % class 1 near (3,3)
  B = [randn(20, 2) * 0.1 - 3];   % class 2 near (-3,-3)
  F = [A; B];
  y = [ones(20, 1); 2 * ones(20, 1)];
  model = pinv_classify('fit', F, y, 1e-2);
  pred = pinv_classify('predict', model, F);
  assert(mean(pred == y) == 1, 'pinv_classify should separate two clusters perfectly');
end
