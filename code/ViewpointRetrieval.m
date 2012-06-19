function [P,n] = ViewpointRetrieval(imgPainting,CameraStruct,ProbInlier,gistScene,doDisplay)
% Retrieves top viewpoints based on gist matching.
%
% Inputs:
% imgPainting - Painting
% CameraStruct - Structure with sampled viewpoints of 3D model
% ProbInlier - ???
% gistScene - (Optional) Pre-computed gist features for sampled viewpoints
%
% Outputs:
% P - 3x4xN Camera matrices corresponding to top N nearest neighbors.
% n - 1xN Indices into CameraStruct of top N nearest neighbors.

if ~exist('doDisplay','var')
  % Set this to 1 to visualize top retrieved nearest neighbors:
  doDisplay = 0;
end

% Gist parameters:
Nblocks = 4;
imageSize = 128; 
orientationsPerScale = [8 8 4];
numberBlocks = 4;
G = createGabor(orientationsPerScale,imageSize);

% Get painting aspect ratio:
aspectRatio = size(imgPainting,1)/size(imgPainting,2);

% Compute gist descriptor of painting:
gistPainting = gistGabor(prefilt(mean(double(imresize(imgPainting,[imageSize imageSize],'bicubic')),3),4),numberBlocks,G);

if ~exist('gistScene','var') || isempty(gistScene)
  % Compute gist descriptors of scene images:
  gistScene = [];
  for i = 1:length(CameraStruct)
    display(sprintf('Computing gist for synthesized viewpoints: %d out of %d',i,length(CameraStruct)));
    
    % Get synthesized viewpoint:
    img = imread(CameraStruct(i).imgName);
    
    % Crop image to have same aspect ratio as painting:
    nrows = round(size(img,2)*aspectRatio);
    ncols = round(size(img,1)/aspectRatio);
    if nrows <= size(img,1)
      ncols = size(img,2);
    else
      nrows = size(img,1);
    end
    imgCrop = img(size(img,1)/2-nrows/2+1:size(img,1)/2+nrows/2,floor(size(img,2)/2)-floor(ncols/2)+1:floor(size(img,2)/2)+floor(ncols/2),:);
    
    % Compute gist:
    g = gistGabor(prefilt(mean(double(imresize(imgCrop,[imageSize imageSize],'bicubic')),3),4),numberBlocks,G);
    if isempty(gistScene)
      gistScene = zeros(length(g),length(CameraStruct));
    end
    gistScene(:,i) = g;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Note: Computing gist features takes a while.  You may save the features
  % at this point to cache them for later use.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% $$$ % Debugging: check against pre-computed gist features:
% $$$ sum(sum(abs(GIST.gistPainting-gistPainting)))
% $$$ sum(sum(abs(GIST.gistScene-gistScene)))
% $$$ max(max(abs(GIST.gistScene-gistScene)))
% $$$ FOO.gistPainting = gistPainting;
% $$$ FOO.gistScene = gistScene;
end


% Normalize gist descriptors to be unit length:
gistPainting = gistPainting/sqrt(sum(gistPainting.^2));
gistScene = gistScene./repmat(sqrt(sum(gistScene.^2,1)),size(gistScene,1),1);;

% Find NN using gist:
d = sum((gistScene-repmat(gistPainting,1,length(CameraStruct))).^2,1);
[v,n] = sort(d);

% Perform non-max suppression:
n = nonMaxSuppress(n,ProbInlier);

% Get camera matrices for top viewpoints:
P = zeros(3,4,length(n),'single');
for i = 1:length(n)
  P(:,:,i) = getGistViewpoint(CameraStruct,n(i),size(imgPainting));
end

if doDisplay
  % Display retrieved nearest neighbors:
  figure;
  for i = 1:9
    % Get synthesized viewpoint:
    img = imread(CameraStruct(n(i)).imgName);
    
    % Crop image to have same aspect ratio as painting:
    nrows = round(size(img,2)*aspectRatio);
    ncols = round(size(img,1)/aspectRatio);
    if nrows <= size(img,1)
      ncols = size(img,2);
    else
      nrows = size(img,1);
    end
    imgCrop = img(size(img,1)/2-nrows/2+1:size(img,1)/2+nrows/2,floor(size(img,2)/2)-floor(ncols/2)+1:floor(size(img,2)/2)+floor(ncols/2),:);
    
    subplot(3,3,i);
    imshow(imgCrop);
    drawnow;
  end
end

