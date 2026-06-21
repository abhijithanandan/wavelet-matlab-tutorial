function Y = upscale(stack, f)
% UPSCALE  Enlarge each slice of an H x W x K stack by an integer factor f.
%   Nearest-neighbour, used only to make the small images easier to see.
  [H, W, K] = size(stack);
  Y = zeros(H * f, W * f, K);
  for i = 1:K, Y(:, :, i) = kron(stack(:, :, i), ones(f, f)); end
end
