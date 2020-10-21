%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
t_start = tic;

% Initialize indices
loop = 0;
i = 0;

% Initialize height and width
height_px = 600;
width_px = 800;

if store
  % Create a movie array
  a = dir([src, '/', src(end - 6:end), '_C1', '/*.jpg']);
  nr_total_frames = numel(a);
  % Sequence of RGB images (height x width x 3 x frames)
  movie = zeros(height_px, width_px, 3, nr_total_frames, 'uint8');
end

if gif
  % Define gif size
  num_gif_images = size(gif_image_raw, 4);

  % construct an empty movie by initializing dimensions
  gif_image = zeros(height_px, width_px, 3, num_gif_images, 'uint8');

  for j = 1:num_gif_images
    % choose frame and convert it
    % Multiply with 255: colormaps read in from GIFs represent colors
    % in the range 0 to 1, rather than integers 0 to 255
    gif_frame_raw = gif_image_raw(:, :, :, j);
    gif_frame_rgb = uint8(255 * ind2rgb(gif_frame_raw, cmap));

    % resize image and define background
    gif_image(:, :, :, j) = imresize(gif_frame_rgb, [height_px, width_px]);
  end

end

%% Generate Movie
%current frame number (middle frame in tensor "left")

while loop ~= 1
  i = i + 1;
  % Get next image tensors
  [left, right, loop] = ir.next();
  % Generate binary mask
  mask = segmentation(left, right);

  % GIF background?
  if gif
    bg = gif_image(:, :, :, mod(i, num_gif_images) + 1);
  end

  % Render new frame
  if store
    movie(:, :, :, i) = render(left(:, :, 1:3), mask, bg, mode);
    %imshow(movie(:,:,:,i));
  else
    imshow(render(left(:, :, 1:3), mask, bg, mode));
  end

end

%% Stop timer here
elapsed_time = toc(t_start);
fprintf('Elapsed time: %.3f seconds = %.3f minutes\n', elapsed_time, elapsed_time / 60);

%% Write Movie to Disk
if store
  % default frame rate for the VideoWriter object is 30 frames per second
  v = VideoWriter(dest, 'Motion JPEG AVI');
  v.Quality = 75;
  open(v);

  for j = 1:i
    frame = im2frame(movie(:, :, :, j));
    writeVideo(v, frame);
  end

  close(v);
end
