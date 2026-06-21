function test_make_texture_subset()
% Build a tiny synthetic dataset on disk: 2 classes, 6 images each.
  root = tempname();
  mkdir(root);
  for c = 1:2
    cdir = fullfile(root, sprintf('class%d', c));
    mkdir(cdir);
    for k = 1:6
      img = uint8(40 * c + 10 * k) * ones(20, 25);   % distinct, non-square
      imwrite(img, fullfile(cdir, sprintf('img%02d.png', k)));
    end
  end
  outp = [tempname(), '.mat'];
  make_texture_subset(root, outp, 16, 4, 2, 2, 0);

  d = load(outp);
  assert(isequal(size(d.Xtrain), [16 16 8]), 'Xtrain size wrong');   % 2 classes * 4
  assert(isequal(size(d.Xtest), [16 16 4]), 'Xtest size wrong');     % 2 classes * 2
  assert(strcmp(class(d.Xtrain), 'uint8'), 'Xtrain must be uint8');
  assert(isequal(sort(unique(d.ytrain(:))), [1; 2]), 'labels must be 1..2');
  assert(numel(d.ytrain) == 8 && numel(d.ytest) == 4, 'label counts wrong');
end
