function test_haar_dwt()
% One 2x2 block: check the four closed-form sub-band values.
  x = [1 2; 3 4];
  [LL, LH, HL, HH] = haar_dwt(x);
  assert(abs(LL - 2.5) < 1e-12, 'LL wrong');
  assert(abs(LH - (-1)) < 1e-12, 'LH wrong');
  assert(abs(HL - (-0.5)) < 1e-12, 'HL wrong');
  assert(abs(HH - 0) < 1e-12, 'HH wrong');

% A 4x4 input must give 2x2 sub-bands, and a constant image must give zero
% detail and a constant approximation.
  c = 7 * ones(4, 4);
  [LL2, LH2, HL2, HH2] = haar_dwt(c);
  assert(isequal(size(LL2), [2 2]), 'LL size wrong');
  assert(max(abs(LH2(:))) < 1e-12 && max(abs(HL2(:))) < 1e-12 && max(abs(HH2(:))) < 1e-12, ...
         'constant image must have zero detail');
  assert(max(abs(LL2(:) - 7)) < 1e-12, 'constant image approximation must stay constant');

% Odd dimensions must error.
  err = false;
  try, haar_dwt(ones(3, 4)); catch, err = true; end
  assert(err, 'odd dimensions should raise an error');
end
