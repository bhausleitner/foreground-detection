 function [mask] = segmentation(left, right)
    % AUTHOR: Johannes Teutsch
    % This function determines the foreground-mask of the first image of the
    % left camera ( i.e., left(:,:,1:3) ).
    % Stereo-information is not needed for this method, so the tensor 
    % "right" is not used.

    % left: tensor of current image + N follow-up images from left camera
    % right: tensor of the current image + N follow-up images from right camera
    % mask: segmentation mask - entries with 1: foreground
    % in- and output variables are of type uint8
        

    %% Background estimation
    %Number of follow-up images
    N = size(left, 3) / 3 - 1;

    %Initialize background estimate
    bg = uint8(zeros(size(left(:, :, 1:3))));

    bg_frames=[1,(N + 1) * 3 - 2];                %only first and last element of tensor is taken for rough background-estimation -> faster
    %bg_frames = 1:3:(N + 1) * 3 - 2;             %take every element of tensor for background-estimation
    
    %Estimate background via median of images
    bg(:, :, 1) = uint8(median(left(:, :, bg_frames    ), 3));        %red
    bg(:, :, 2) = uint8(median(left(:, :, bg_frames + 1), 3));        %green
    bg(:, :, 3) = uint8(median(left(:, :, bg_frames + 2), 3));        %blue
  
    %% Movement Detection:
  
    % Idea: the foreground is detected by substracting the background from the
    % images and compare the error between the 1st image and the 3rd image 
    % to detect motion. Additionally, differences in detected edges of those
    % images is taken into account.

    % NOTE: substracting variables of type uint8 gives 0 instead of negative
    % values! This is used here to give 'positive' and 'negative' deviations
    % different weights / thresholds in the detection.
    
    %median of background: is added when substracting the background to
    %keep the overall brightness, but later cancelled out in the
    %substraction of following and previous image.
    bg_med = median(bg,'all');

    %positive deviation: image brighter than background
    dev_pos_nxt = rgb2gray(left(:, :, 3*(3)-2:3*(3)) - bg) + bg_med;  %third image
    dev_pos_cur = rgb2gray(left(:, :, 1:3) - bg) + bg_med;            %current image

    %negative deviation: background brighter than image
    dev_neg_nxt = rgb2gray(bg - left(:, :, 3*(3)-2:3*(3))) + bg_med;  %third image
    dev_neg_cur = rgb2gray(bg - left(:, :, 1:3)) + bg_med;            %current image

    %threshold for positive deviation:
    thr_pos = 9;

    %threshold for negative deviation:
    thr_neg = 12;

    %first raw mask:
    mask = (imabsdiff(dev_pos_nxt,dev_pos_cur) > thr_pos) | (imabsdiff(dev_neg_nxt,dev_neg_cur)> thr_neg); 

    %Removing noise (pixel areas < 30)
    mask = bwareaopen(mask, 30,8);

    %% Edge Detection: 
    
    edg_window=imdilate(mask,strel('square',30));         %Take only the edge near the already detected mask
    edg1=edge(rgb2gray(left(:, :, 3*(3)-2:3*(3))),'Sobel',0.01).*edg_window;
    edg2=edge(rgb2gray(left(:, :, 1:3)),'Sobel',0.01).*edg_window;

    %Adding the detected difference in edges to the mask, diltate edges (thickening)
    mask = mask | bwmorph(bitxor(uint8(edg1), uint8(edg2)),'dilate');
    
    %% Post Processing:
    
    %Removing noise
    mask = bwareaopen(mask, 50,8);

    %Connecting close pixels to clusters
    mask=bwmorph(mask, 'majority',2);
    mask=bwmorph(mask, 'close',2);

    %Remove areas < 4000 (for small false-detected areas)
    mask = bwareaopen(mask, 4000,8);

    %Fill holes and "bays" by operating on inverse mask
    mask = ~imopen(bwareaopen(~mask, 10000,8),strel('square',60));

    %Fill remaining holes 
    mask(end-1,find(mask(end-1,:),1,'first'):find(mask(end-1,:),1,'last'))=1;  %this is used to close bays (i.e., get holes) at the bottom of the image
    mask=imfill(mask,'holes');

    %Smooth edges of mask
    mask=imclose(mask,strel('disk',20));
    mask=imopen(mask,strel('disk',7));

    %convertion to uint8, so that the mask can later be used like: img.*mask      
    mask = uint8(mask);

 end
