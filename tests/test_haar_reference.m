function test_haar_reference()
% Check the shared haar_dwt against values computed independently for a fixed
% 4x4 input. The reference numbers are the standard Haar (averaging) sub-bands
% for non-overlapping 2x2 blocks, verified by hand and matching pywt's 'haar'
% with the (1/2,1/2)/(1/2,-1/2) normalisation.
  x = [ 1  2  3  4;
        5  6  7  8;
        9 10 11 12;
       13 14 15 16];
  [LL, LH, HL, HH] = haar_dwt(x);
  LL_ref = [ 3.5  5.5; 11.5 13.5];
  LH_ref = [-2 -2; -2 -2];
  HL_ref = [-0.5 -0.5; -0.5 -0.5];
  HH_ref = [ 0  0;  0  0];
  assert(max(abs(LL(:) - LL_ref(:))) < 1e-12, 'LL mismatch');
  assert(max(abs(LH(:) - LH_ref(:))) < 1e-12, 'LH mismatch');
  assert(max(abs(HL(:) - HL_ref(:))) < 1e-12, 'HL mismatch');
  assert(max(abs(HH(:) - HH_ref(:))) < 1e-12, 'HH mismatch');
end
