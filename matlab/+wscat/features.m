function F = features(X)
% WSCAT.FEATURES  Second-order wavelet scattering features (no training).
%   F = WSCAT.FEATURES(X) takes images X (H x W x N) and returns a feature
%   matrix F (N x D). This is the advanced version of the tutorial's
%   scatter_features: it runs a 4-level cascade on the approximation (first
%   order) and, at the first level, decomposes the modulus of each detail band
%   one more time (second order), which captures how the texture's fine detail
%   is itself organised. Each kept sub-band is reduced to a single global
%   average. The Haar transform is the shared haar_dwt from common/; nothing is
%   trained.
  N = size(X, 3);
  first = scatter_one(X(:, :, 1));
  F = zeros(N, numel(first));
  F(1, :) = first(:).';
  for n = 2:N
    F(n, :) = reshape(scatter_one(X(:, :, n)), 1, []);
  end
end


function f = scatter_one(img)
  n_levels = 4;
  f = [];
  cur = double(img);
  for lvl = 1:n_levels
    [LL, LH, HL, HH] = haar_dwt(cur);
    highs = {abs(LH), abs(HL), abs(HH)};
    for hb = 1:numel(highs)
      U = highs{hb};
      f = [f; mean(U(:))];                       % first-order coefficient
      if lvl == 1 && min(size(U)) >= 2           % second order from level 1
        [LL2, LH2, HL2, HH2] = haar_dwt(U);
        f = [f; mean(abs(LH2(:))); mean(abs(HL2(:))); mean(abs(HH2(:)))];
        f = [f; mean(LL2(:))];
      end
    end
    cur = LL;
  end
  f = [f; mean(cur(:))];                          % final approximation
end
