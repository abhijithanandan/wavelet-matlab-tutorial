function out = pinv_classify(mode, varargin)
% PINV_CLASSIFY  Closed-form linear classifier using the pseudo-inverse.
%   model = PINV_CLASSIFY('fit', F, y)           fit on features F (N x D) and
%                                                labels y (N x 1, values 1..C)
%   model = PINV_CLASSIFY('fit', F, y, lambda)   with ridge strength lambda
%   pred  = PINV_CLASSIFY('predict', model, F)   predict labels for new features
%
%   There is NO training loop. We standardise each feature, write the labels as
%   one-hot columns, and solve one linear least-squares system for the weights:
%       W = (Z'Z + lambda I) \ (Z'Y)
%   This is the pseudo-inverse (least-squares) solution. Prediction is the
%   column with the largest score.
  switch mode
    case 'fit'
      F = varargin{1};
      y = varargin{2};
      lambda = 1e-2;
      if numel(varargin) >= 3 && ~isempty(varargin{3}), lambda = varargin{3}; end

      mu = mean(F, 1);                 % per-feature mean and spread, from train
      sd = std(F, 0, 1); sd(sd == 0) = 1;
      Z = (F - mu) ./ sd;              % standardise
      Zb = [Z, ones(size(Z, 1), 1)];   % add a bias column

      C = max(y);
      Y = zeros(numel(y), C);          % one-hot targets
      for i = 1:numel(y), Y(i, y(i)) = 1; end

      D = size(Zb, 2);
      W = (Zb.' * Zb + lambda * eye(D)) \ (Zb.' * Y);
      out = struct('mu', mu, 'sd', sd, 'W', W);

    case 'predict'
      model = varargin{1};
      F = varargin{2};
      Z = (F - model.mu) ./ model.sd;
      Zb = [Z, ones(size(Z, 1), 1)];
      [~, out] = max(Zb * model.W, [], 2);

    otherwise
      error('pinv_classify: unknown mode %s', mode);
  end
end
