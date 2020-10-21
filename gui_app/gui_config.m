% basic configuration after parameters in gui have been set
ir = ImageReader(src, L, R, start, N);

% distinguish between jpg and gif
% copied from conifg.m
try
  [gif_image_raw, cmap] = imread(bg_name, 'Frames', 'all');
  gif = 1;
catch
  bg = imread(bg_name);
  gif = 0;
end