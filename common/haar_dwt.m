function [LL, LH, HL, HH] = haar_dwt(x)
% HAAR_DWT  One level of the 2-D Haar wavelet transform, as plain filters.
%   [LL, LH, HL, HH] = HAAR_DWT(x) splits the image x into four half-size
%   sub-bands using the Haar wavelet. No toolbox is used: the transform is the
%   separable low-pass filter [1/2 1/2] and high-pass filter [1/2 -1/2] applied
%   along columns and rows, with a factor-2 downsample. In plain terms, every
%   non-overlapping 2x2 block [p q; r s] of the image becomes one number in each
%   sub-band:
%       LL = (p + q + r + s) / 4    the local average (approximation)
%       LH = (p + q - r - s) / 4    top row minus bottom row (horizontal edges)
%       HL = (p - q + r - s) / 4    left column minus right column (vertical edges)
%       HH = (p - q - r + s) / 4    the diagonal detail
%   LL is the approximation that the next level decomposes again.
  [H, W] = size(x);
  if mod(H, 2) ~= 0 || mod(W, 2) ~= 0
    error('haar_dwt: image dimensions must be even, got %dx%d', H, W);
  end
  x = double(x);
  p = x(1:2:end, 1:2:end);   % top-left of each 2x2 block
  q = x(1:2:end, 2:2:end);   % top-right
  r = x(2:2:end, 1:2:end);   % bottom-left
  s = x(2:2:end, 2:2:end);   % bottom-right
  LL = (p + q + r + s) / 4;
  LH = (p + q - r - s) / 4;
  HL = (p - q + r - s) / 4;
  HH = (p - q - r + s) / 4;
end
