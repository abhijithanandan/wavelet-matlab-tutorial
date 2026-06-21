function out = softmax_classify(mode, varargin)
% SOFTMAX_CLASSIFY  A linear classifier TRAINED by gradient descent.
%   Same inputs and outputs as pinv_classify, but instead of one closed-form
%   pseudo-inverse solve it LEARNS the weights step by step, the usual way
%   neural networks are trained. We use it only to compare a trained classifier
%   against the pseudo-inverse (no-training) one on the same features.
%
%   model = SOFTMAX_CLASSIFY('fit', F, y)
%   pred  = SOFTMAX_CLASSIFY('predict', model, F)
  switch mode
    case 'fit'
      F = varargin{1};
      y = varargin{2};
      iters = 400; lr = 0.5; lam = 1e-4;       % training settings

      mu = mean(F, 1); sd = std(F, 0, 1); sd(sd == 0) = 1;
      Z = [(F - mu) ./ sd, ones(size(F, 1), 1)];   % standardise + bias column
      C = max(y); N = size(Z, 1); D = size(Z, 2);
      Y = zeros(N, C); for i = 1:N, Y(i, y(i)) = 1; end

      W = zeros(D, C);
      for it = 1:iters                          % gradient descent on cross-entropy
        S = Z * W; S = S - max(S, [], 2);
        P = exp(S); P = P ./ sum(P, 2);          % softmax probabilities
        G = Z.' * (P - Y) / N + lam * W;         % gradient
        W = W - lr * G;
      end
      out = struct('mu', mu, 'sd', sd, 'W', W);

    case 'predict'
      model = varargin{1};
      F = varargin{2};
      Z = [(F - model.mu) ./ model.sd, ones(size(F, 1), 1)];
      [~, out] = max(Z * model.W, [], 2);

    otherwise
      error('softmax_classify: unknown mode %s', mode);
  end
end
