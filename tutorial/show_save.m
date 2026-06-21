function show_save(M, ttl, png_path, display_ok)
% SHOW_SAVE  Save a montage image as a PNG, and show it on screen if possible.
%   The PNG is always written (so the script also works with no display); the
%   on-screen figure is only drawn when a display is available.
  imwrite(uint8(255 * M), png_path);
  if display_ok
    figure('Name', ttl);
    imagesc(M); axis image off; colormap(gray); title(ttl);
  end
end
