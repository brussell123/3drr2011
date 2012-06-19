function [map,mapNdx] = pointsToMap(x,y,t,imageSize,Norientations)
% Inputs:
% x - Set of X image points
% y - Set of Y image points
% t - Orientation indices for points
% imageSize - [M N]
% Norientations - Number of orientations K
%
% Outputs:
% map - MxNxK binary map

% Round points:
x = round(x);
y = round(y);

if nargout >= 2
  ndx = 1:length(x);
end

% Get valid points:
n = find((x>=1)&(x<=imageSize(2))&(y>=1)&(y<=imageSize(1)));
x = x(n);
y = y(n);
t = t(n);

if nargout >= 2
  ndx = ndx(n);
  mapNdx = zeros(imageSize(1),imageSize(2),Norientations);
end

map = logical(zeros(imageSize(1),imageSize(2),Norientations));
for i = 1:Norientations
  % Get points for current orientation:
  j = find(t==i);
  
  % Form binary map for current orientation:
  bi = logical(zeros(imageSize(1),imageSize(2)));
  n = sub2ind(size(bi),y(j),x(j));
  bi(n) = 1;
  map(:,:,i) = bi;

  if nargout >= 2
    nn = zeros(imageSize(1),imageSize(2));
    nn(n) = ndx(j);
    mapNdx(:,:,i) = nn;
  end
end

return;

addpath ~/work/Archaeology/BundlerToolbox_v03;
addpath ./sc_demo;
addpath ~/work/Archaeology/MeshCode/ToolboxCopy;
addpath ~/work/Archaeology/MeshCode;
addpath ~/work/MatlabLibraries/BerkeleyPB;
addpath ~/work/Archaeology/MeshCode/EstimateCamera;
addpath ~/Desktop/NACHO/p4pf;

% Painting 02:
PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting02.jpg';
cNdx = 2846; % Camera index
% $$$ cNdx = 2808; % Better viewpoint (not top gist match)
fname2 = '~/work/Archaeology/MeshCode/EstimateCamera/ImagesToMatch/Painting/img007_pb.jpg';
fname2 = '~/Desktop/FOO/globalPb/img/gpb_painting_02_fullres.bmp';
PAINTING_LINES = '~/work/Archaeology/MeshCode/EstimateCamera/paintingLines02.mat';
is_gpb = 1;

% Read painting:
imgPainting = imread(PAINTING_FNAME);
imageSizePainting = size(imgPainting);

% Read PB for painting:
% $$$ PaintingLinesStruct = load(PAINTING_LINES);
% $$$ V2 = 1-PaintingLinesStruct.imgPB;
V2 = imread(fname2);
V2 = mean(double(V2),3)/255;
if is_gpb
  V2 = 1-V2;
end

% Get painting features:
[V2pb,V2theta,V2] = paintingFeatures(V2,imgPainting);
V2pb = hysterisis(V2pb);

% Get points:
[y,x] = find(V2pb>0.05);
t = V2theta(V2pb>0.05);

Norient = 8;
angBins = linspace(0,pi,Norient+1);
[aa,t] = ismember(t,angBins);

map = pointsToMap(x,y,t,imageSizePainting,Norient);
