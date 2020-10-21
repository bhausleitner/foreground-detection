# cv_challenge
Coding challenge for the computer vision lecture at TUM.
Used dataset: http://arma.sourceforge.net/chokepoint/

## Best practice
To get the best result, please use the following settings:

The following MATLAB Toolboxes are mandatory:
- Image Processing Toolbox
- Parallel Computing Toolbox
- Mapping Toolbox

To run the code without the GUI, set the following parameters inside config.m and run the script:
- `src`: Source Path pointing to the source folder of the ChokePoint dataset, string or char array
- `L`: Selection for left videostream, numeric values {1,2}
- `R`: Selection for right videostream, numeric values {2,3}
- `start`: Starting frame number for segmentation, numeric inbetween framenumber range of folder (optional)
- `bg_name`: Name of the background image / video. This needs to be of type jpg, png or gif (for videos). Note that the corresponding file has to lie in the same folder ad config.m
- `mode`: Rendering mode, variable of type string, either "foreground", "background", "overlay", or "substitute".
- `store`: Flag which states to store the resulting movie or not, logical values {true, false}. If `store = true`, then the current rendered image is not shown, and only the resulting movie is stored  with the name "output.avi" and can be viewed. If `store = false`, then each rendered frame is shown.

After config.m was run, challenge.m can be executed to start the rendering and work through all frames of the folder, starting with the frame number `start`.

If the GUI is used, config.m and challenge.m can be neglected, because the GUI subsitutes these scripts. The computation time strongly depends on the avaiable cores of the processor (the used Image Processing functions rely on Parallel Computing methods). On all our computer systems and the EIKON server, the computation time remained under 30 minutes, also for the largest folder. After the script worked through all images, it takes some time to store the movie, so just wait until the "Show Results"-Button on the GUI is available to see the movie (this may take some minutes).

To use an animated background, please use the GIF format.
Therefore, just hand over the desired background to the *bg_name* variable.
To get the best experience, please use GIFs with a dedicated "Download" button (e.g. https://gifer.com/en) and do not right-click and save as image.

## ImageReader

The `ImageReader` converts the respective video stream of the dataset into actionable matrices and tensors. The class constructor returns a class object `ir`.
<!--  `src`: Source Path pointing to the source folder of the ChokePoint dataset, string or char array
- `L`: Selection for left videostream, numeric values {1,2}
- `R`: Selection for right videostream, numeric values {2,3}
- `start`: Starting frame number for segmentation, numeric inbetween framenumber range of folder (optional)
- `N`: Number of returned consecutive frames, numeric -->

The class constructor returns a class object `ir` and can be called the following way:

```matlab
  ir = ImageReader(src, L, R, start, N);
```

As the variable `start` is optional, the constructor can be also called with 4 input variables, setting the variable `start`internally to default value `1`:

```matlab
  ir = ImageReader(src, L, R, N);
```

### next() Method

This public method is part of the `ImageReader` class and iteratively fills up tensors `left` and `right` starting from the prior intialized sarting frame number `start`. This public class method can be called the following way:
<!-- - `left`: Tensor containing left video stream, shape _600 x 800 x (N+1)*3_, numeric
- `right`: Tensor containing right video stream, shape _600 x 800 x (N+1)*3_, numeric
- `loop`: Overflow flag in case ender of frame numer range of folder is reached, numeric values {0,1} --->

```matlab
  [left, right, loop] = ir.next();
```
## Segmentation
The method was developed for `N = 5`, so 5 following images are loaded additonal to the current image. The first and last loaded images are used to roughly estimate the background. Better segmentation results can be retrieved if `N` is increased and all images are used for the background estimation. This can be done by setting `bg_frames = 1:3:(N + 1) * 3 - 2` (i.e., deactivate line 21 and actvate line 22 in segmentation.m). Note that due to the additional computational load, it is not guaranteed that the computation time remains under 30 minutes for all folders. We recommend to use the current setup. If it is desired to change the parameter `N`, note that the segmentation function requires `N>=2`.

## Rendering
Within the render.m file, the rendering of each frame is processed. To accomplish a proper rendering, the segmentation matrix is used to split foreground (i.e. the moving objects) and background (i.e. static objects). In addition, a distinction between the 4 rendering modes is happening here:

- Foreground: Keep the foreground and set the background black.
- Background: Keep the background and set the foreground black.
- Overlay: Set foreground and background to different, but transparent colors.
- Substitute: Keep the foreground and substitute the background with a desired picture or video clip.

## GUI
To start the gui, run
```matlab
  start_gui
```
in the command window in MATLAB. Before being able to run the script, choose a path leading to one of the chokepoint datasets, and a background.
Supported backgorund data types are:
1. jpg
2. png
3. gif

Any other settings are optional. Standard values are:
1. Start Point: 1
2. Rendering Mode: substitute
3. Left Image: Sequence 1
4. Right Image: Sequence 2
5. Output Video Options: do not store a copy of the video

### Known Issues
1. When opening the file selector on MacOS the window opens behind the GUI UI. This is a known issue by MATLAB and might be fixed in the future.
   > [Here](https://de.mathworks.com/matlabcentral/answers/518793-how-to-make-uigetfile-window-pops-up-in-front-of-my-app-designed-in-appdesigner) is a discussion
