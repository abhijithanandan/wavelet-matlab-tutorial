function M = montage_image(stack, cols, pad)
% MONTAGE_IMAGE  Tile a H-by-W-by-K stack of maps into one image.
%   M = MONTAGE_IMAGE(stack, cols, pad) lays the K slices out in a grid so they
%   can be shown with imagesc or saved with imwrite. Each slice is normalised
%   to [0,1] on its own, so its pattern is visible regardless of scale.
  if nargin < 2 || isempty(cols), cols = ceil(sqrt(size(stack, 3))); end
  if nargin < 3 || isempty(pad), pad = 1; end

  [H, W, K] = size(stack);
  rows = ceil(K / cols);
  M = ones(rows * (H + pad) + pad, cols * (W + pad) + pad);   % white gaps

  for idx = 1:K
    s = stack(:, :, idx);
    lo = min(s(:)); hi = max(s(:));
    if hi > lo
      s = (s - lo) / (hi - lo);
    else
      s = zeros(size(s));
    end
    r = floor((idx - 1) / cols);
    c = mod(idx - 1, cols);
    M(pad + r * (H + pad) + (1:H), pad + c * (W + pad) + (1:W)) = s;
  end
end
