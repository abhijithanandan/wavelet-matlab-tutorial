function make_texture_subset(input_dir, output_path, sz, ntrain, ntest, nclasses, seed)
% MAKE_TEXTURE_SUBSET  Build a small bundled texture dataset (.mat) from a folder.
%   make_texture_subset(input_dir, output_path, sz, ntrain, ntest, nclasses, seed)
%   reads input_dir, which has one subfolder per texture class. It loads images,
%   converts them to grayscale, resizes them to sz x sz, and splits each class
%   into train and test. The result is saved as output_path with variables
%   Xtrain, ytrain, Xtest, ytest. This is a development tool: the deliverable
%   ships the .mat it produces, so the student never runs this.
  if nargin < 3 || isempty(sz), sz = 64; end
  if nargin < 4 || isempty(ntrain), ntrain = 40; end
  if nargin < 5 || isempty(ntest), ntest = 40; end
  if nargin < 6 || isempty(nclasses), nclasses = 6; end
  if nargin < 7 || isempty(seed), seed = 0; end

  entries = dir(input_dir);
  names = {entries([entries.isdir]).name};
  names = names(~ismember(names, {'.', '..'}));
  names = sort(names);
  if numel(names) < nclasses
    error('make_texture_subset: need %d classes, found %d', nclasses, numel(names));
  end
  names = names(1:nclasses);

  Xtr = zeros(sz, sz, nclasses * ntrain, 'uint8');
  Xte = zeros(sz, sz, nclasses * ntest, 'uint8');
  ytr = zeros(nclasses * ntrain, 1);
  yte = zeros(nclasses * ntest, 1);

  rng(seed);             % seed the generator that randperm draws from, reproducibly
  ti = 0; ei = 0;
  for c = 1:nclasses
    cdir = fullfile(input_dir, names{c});
    files = dir(cdir);
    files = {files(~[files.isdir]).name};
    files = sort(files);
    if numel(files) < ntrain + ntest
      error('make_texture_subset: class %s has %d images, need %d', ...
            names{c}, numel(files), ntrain + ntest);
    end
    order = randperm(numel(files));
    files = files(order);

    for k = 1:ntrain
      ti = ti + 1;
      Xtr(:, :, ti) = load_gray_resized(fullfile(cdir, files{k}), sz);
      ytr(ti) = c;
    end
    for k = 1:ntest
      ei = ei + 1;
      Xte(:, :, ei) = load_gray_resized(fullfile(cdir, files{ntrain + k}), sz);
      yte(ei) = c;
    end
  end

  Xtrain = Xtr; ytrain = ytr; Xtest = Xte; ytest = yte; %#ok<NASGU>
  save('-mat', output_path, 'Xtrain', 'ytrain', 'Xtest', 'ytest');
end


function out = load_gray_resized(path, sz)
% Read an image, make it grayscale, resize to sz x sz with bilinear interp.
  img = double(imread(path));
  if ndims(img) == 3, img = mean(img, 3); end   % average the colour channels
  [H, W] = size(img);
  [Xq, Yq] = meshgrid(linspace(1, W, sz), linspace(1, H, sz));
  out = uint8(interp2(img, Xq, Yq, 'linear'));
end
