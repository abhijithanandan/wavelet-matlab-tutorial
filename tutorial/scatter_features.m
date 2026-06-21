function F = scatter_features(X, n_levels, g)
% SCATTER_FEATURES  Multi-level wavelet transform features (no training).
%   F = SCATTER_FEATURES(X, n_levels, g) takes images X (H x W x N) and returns
%   a feature matrix F (N x D). This is the ordinary multi-level wavelet transform
%   used in the 2018 Wavelet CNN paper (not the scattering transform, which is the
%   optional variant in matlab/+wscat). For each image it:
%     1. splits the image into LL, LH, HL, HH with haar_dwt,
%     2. takes the magnitude of the high-pass sub-bands,
%     3. average-pools each one into a small g x g grid of numbers,
%     4. feeds the LL approximation back in and repeats for n_levels levels,
%     5. also pools the final LL approximation,
%     6. stacks everything into one feature vector.
%   Nothing is learned: the filters are the fixed Haar wavelet and there is no
%   training. The pooling grid g keeps a little spatial layout while giving some
%   tolerance to small shifts.
  if nargin < 2 || isempty(n_levels), n_levels = 3; end
  if nargin < 3 || isempty(g), g = 4; end

  N = size(X, 3);
  first = scatter_one(X(:, :, 1), n_levels, g);
  D = numel(first);
  F = zeros(N, D);
  F(1, :) = first(:).';
  for n = 2:N
    f = scatter_one(X(:, :, n), n_levels, g);
    F(n, :) = f(:).';
  end
end


function f = scatter_one(img, n_levels, g)
% Scattering cascade for a single image, returned as a column vector.
  f = [];
  cur = double(img);
  for lvl = 1:n_levels
    [LL, LH, HL, HH] = haar_dwt(cur);
    f = [f; pool_grid(abs(LH), g); pool_grid(abs(HL), g); pool_grid(abs(HH), g)];
    cur = LL;
  end
  f = [f; pool_grid(cur, g)];
end


function v = pool_grid(M, g)
% Average-pool a matrix M into a g x g grid, returned as a g*g column vector.
% The rows and columns are split into g near-equal bands; each cell is the mean
% of its block. Works for any M whose sides are at least g.
  [H, W] = size(M);
  if H < g || W < g
    error('pool_grid: matrix is %dx%d but needs at least %dx%d to pool into a %d-by-%d grid', H, W, g, g, g, g);
  end
  ri = round(linspace(0, H, g + 1));
  ci = round(linspace(0, W, g + 1));
  P = zeros(g, g);
  for a = 1:g
    for b = 1:g
      blk = M(ri(a) + 1:ri(a + 1), ci(b) + 1:ci(b + 1));
      P(a, b) = mean(blk(:));
    end
  end
  v = P(:);
end
