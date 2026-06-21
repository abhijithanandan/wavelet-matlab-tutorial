function test_scatter_features()
  g = 4; L = 3;
% Feature dimension must be (3*L + 1) * g*g.
  X = rand(64, 64, 2);
  F = scatter_features(X, L, g);
  assert(isequal(size(F), [2, (3 * L + 1) * g * g]), 'feature matrix has wrong size');

% A constant image has zero high-pass detail at every level, and its LL
% approximation equals the constant. So all high-pass features are 0 and the
% final g*g approximation features equal the constant.
  v = 0.3;
  Xc = v * ones(64, 64, 1);
  Fc = scatter_features(Xc, L, g);
  nhigh = 3 * L * g * g;
  assert(max(abs(Fc(1, 1:nhigh))) < 1e-12, 'constant image must have zero high-pass features');
  assert(max(abs(Fc(1, nhigh+1:end) - v)) < 1e-12, 'constant image approximation features must equal the constant');
end
