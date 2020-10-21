%% ImageReader
% Author: Berni Hausleitner
% Log:  - 20200621: Setting up initial structure and constructor of class
%       - 20200622: Setting up next method
%       - 20200625: Bug Fixes for input handling and start param update

% TODO: - call next() without class

% function should be able to process two videostreams from one folder into
% an endless loop

% ImageReader will be a class with the method next()

% generate string P**_S*_C*

%% Params
% src: string entailing the different relative/absolute paths
% L: left Camera (1,2)
% R: right Camera (2,3)
% start: framenumber to start with (optional, if nothing: 0)
% N: amount of following frames per reading process (N=1)

%% Methods
% next: "left,right,loop = ir.next()"
% -> params:
%           - left: tensor with frames of left camera 600x800x(N+1)*3
%           - right: tensor with frames of right camera 600x800x(N+1)*3
%           - loop: 0, if not enough pics in folder, just give back the existing ones -> loop = 1
%           -> if loop=1, next call of next() starts at 0000000.jpg

%% How To
% 1: Assign a source:src='ChokePoint/P1E_S1'
% 2: Create an ImageReader-instance: ir=ImageReader(src,1,,2,,1498,50);
% 3: Call the next-method: [left,right,loop,ab] = ir.next();

%% Implementation

classdef ImageReader < handle

  properties
    src % base folder src
    L % which camera should be left cam
    R % which camera should be right cam
    N % amount of following frames, default=1
    targetL % target folder left cam
    targetR % target folder right cam
    startArray % current start of Array Index
    endArray % end of current array, size of current array
    data % cell array with filenames of current list
  end

  methods

%% Constructor for ImageReader
% assigns inputvalues and check validity
    function irObj = ImageReader(src, L, R, varargin) % varargin = [start, N] (start is optional)    
        % Constructor method        
        % assign and check validity of src 
        try irObj.src = char(src);
        catch
            error('Input argument ''src'' must be a string or char.')
        end
        
        % assign check validity of L
        if isnumeric(L) && ((L == 1) || (L == 2))
            irObj.L = L;
            %Read target path for Left Camera
            L_str = num2str(irObj.L);
            irObj.targetL = strcat(irObj.src, irObj.src((end - 6):end), '_C', L_str, '/');
        else
            error('Input argument ''L'' must be numeric and value 1 or 2.')
        end
        
        % assign check validity of R
        if isnumeric(R) && ((R == 2) || (R == 3))
            irObj.R = R;
            %Read target path for Right Camera
            R_str = num2str(irObj.R);
            irObj.targetR = strcat(irObj.src, irObj.src((end - 6):end), '_C', R_str, '/'); 
        else
            error('Input argument ''R'' must be numeric and value 2 or 3.')
        end
        
        % Read filenames from text-file in respective folder
        f = fopen(strcat(irObj.targetL, 'all_file.txt'));
        all_files = textscan(f, '%s');
        irObj.data = all_files{1};
        fclose(f);
        
        if nargin ==5
            % assign and check first validity of start (isnumeric)
            if isnumeric(varargin{1}(1))
                if varargin{1}(1) == 0
                    irObj.startArray = 1; % startframe is 00000000.jpg -> array_ind = 1
                else
                    irObj.startArray = varargin{1}(1);
                end
            else
                error('Input argument ''start'' must be numeric.')
            end

            % second validity check of start (is Part of Frame List?)
            % Get startvalue
            if irObj.startArray > size(irObj.data, 1)
                error('Input argument ''start'' must be a valid frame-number.')
            end
            
            
            % assign and check validity of N
            if isnumeric(varargin{2}(1))
                irObj.N = varargin{2}(1);
            else
                error('Input argument ''N'' must be numeric.')
            end

        elseif nargin == 4
            irObj.startArray = 1; % frame is 00000000.jpg -> array_ind = 1
            % assign and check validity of N
            if isnumeric(varargin{1}(1))
                irObj.N = varargin{1}(1);
            else
                error('Input argument ''N'' must be numeric.')
            end 
        else
          error('Wrong number of input arguments')
        end      
        
    end
    
%% next()-method
% Function for getting the next N+1 images
% The image list for all subfolders in a folder P**_S* is identical
% This algorithm takes image list from left camera as reference
% exp: N=2: next() -> frame21,frame22,frame23; next() -> frame22,frame23,frame24 

    function [left, right, loop] = next(irObj)
      % Function for getting the next N+1 images
      % The image list for all subfolders in a folder P**_S* is identical
      % This algorithm takes image list from left camera as reference

      % Initialize containers
      left = []; right = []; loop=0;
      
      % End of this filenames list
      irObj.endArray = size(irObj.data, 1);

      % Get N+1 images and stack them into 600x800x[(N+1)*3]
      for ind = irObj.startArray:(irObj.startArray + irObj.N)
        %display(strcat('startArray is', num2str(ind)));

        if ind <= irObj.endArray
          
          % If current index is smaller/equal the end of the list
          loop = 0;
          % Call path and get current image
          currentImageL = imread(strcat(irObj.targetL, irObj.data{ind}));
          currentImageR = imread(strcat(irObj.targetR, irObj.data{ind}));

          % Stack image into 600x800x[(N+1)*3]
          left = cat(3, left, currentImageL);
          right = cat(3, right, currentImageR);
        else
          % If current index is greater the end of the list
          loop = 1;
        end
      end
      
      % Update the start property of the class
      if loop == 0
        % If list did not reach the end yet
        irObj.startArray = irObj.startArray+1;
      else
        % If list did reach the end
        irObj.startArray = 0;
        %disp('Starting from new again')
      end
    end

  end

end
