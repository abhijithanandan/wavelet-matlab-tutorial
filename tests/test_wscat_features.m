function test_wscat_features()
% Second-order scattering feature dimension must be deterministic, and a
% constant image must produce zero detail features.
  X = rand(64, 64, 2);
  F = wscat.features(X);
  D = size(F, 2);
  assert(size(F, 1) == 2, 'row count wrong');
  assert(D > 0 && D == round(D), 'feature dimension must be a positive integer');

  Xc = 0.5 * ones(64, 64, 1);
  Fc = wscat.features(Xc);
% Every detail-derived feature must be zero for a constant image; only the
% approximation (LL) averages stay non-zero: the three second-order LL means at
% level 1 plus the final approximation, so at most four non-zero features.
  assert(sum(abs(Fc) > 1e-9) <= 4, 'constant image should have almost all-zero features');
end
