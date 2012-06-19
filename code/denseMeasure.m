function [score,xout,yout,isValid,tout,costMap] = denseMeasure(map1,map2,inlierThresh)
% Inputs:
% map1 - MxNxK binary map of destination (3D model)
% map2 - MxNxK binary map of proposal (painting)
% inlierThresh - Inlier threshold
%
% Outputs:
% score - Mean distance

map2 = double(map2);
[M,N,K] = size(map1);
score = 0;
if nargout > 1
  xout = zeros(M,N);
  yout = zeros(M,N);
  isValid = logical(zeros(M,N));
  tout = zeros(M,N);
  costMap = inf*ones(M,N);
end
for i = 1:K
  m1 = squeeze(map1(:,:,i));
  m2 = map2(:,:,i);
  
  % Compute distance transform of 3D model points:
  [distMap1,ndx] = bwdist(m1,'euclidean');
  distMap1 = min(distMap1,inlierThresh);
  score = score + sum(sum(distMap1.*m2));

  if nargout > 1
    % Get inlier painting edge points:
    nn = find((distMap1<inlierThresh)&(m2==1));
    
    % Get cost for inlier painting edge points:
    cc = inf*ones(M,N);
    cc(nn) = distMap1(nn);
    
    % Find inlier painting edge points that have best cost so far (across
    % different orientations):
    ndx2 = find(cc<costMap);

    % Set values for best-cost inlier painting edge points:
    costMap(ndx2) = cc(ndx2);
    tout(ndx2) = i; % 3D model orientation
    [yy,xx] = ind2sub(size(distMap1),ndx(ndx2));
    xout(ndx2) = xx; % projected 3D model x coordinates
    yout(ndx2) = yy; % projected 3D model y coordinates
    isValid(ndx2) = 1; % inlier painting points
    
% $$$     % Get inlier painting edge points:
% $$$     nn = find((distMap1<inlierThresh)&(m2==1));
% $$$     
% $$$     % Get corresponding 3D model points for the inlier painting edge points:
% $$$     [yy,xx] = ind2sub(size(distMap1),ndx(nn));
% $$$     xout(nn) = xx;
% $$$     yout(nn) = yy;
% $$$     isValid(nn) = 1;
% $$$     
% $$$     cc = inf*ones(M,N);
% $$$     cc(nn) = distMap1(nn);
% $$$     ndx2 = find(cc<costMap);
% $$$     costMap(ndx2) = cc(ndx2);
% $$$     tout(ndx2) = i;
  end
end
score = score/sum(sum(sum(map2)));

% $$$ % Compute distance transform of destination:
% $$$ distMap1 = min(bwdist(map1,'euclidean'),inlierThresh);
% $$$ map2 = double(map2);
% $$$ score = sum(sum(distMap1.*map2))/sum(sum(map2));


return;

addpath ~/work/Archaeology/BundlerToolbox_v03;
addpath ./sc_demo;
addpath ~/work/Archaeology/MeshCode/ToolboxCopy;
addpath ~/work/Archaeology/MeshCode;
addpath ~/work/MatlabLibraries/BerkeleyPB;
addpath ~/work/Archaeology/MeshCode/EstimateCamera;
addpath ~/Desktop/NACHO/p4pf;

% "New2" trimmed
meshFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
normalsFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
holesFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_holes.txt';

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

Norient = 8;
angBins = linspace(0,pi,Norient+1);
for i = 1:Norient
  clf;
  imshow(V2pb.*(V2theta==angBins(i)));
  ginput(1);
end

% Get initial viewpoint from gist:
load /Users/brussell/work/Archaeology/Data/SynthesizeViewpoints/CameraStructVisible_v3.mat;
focal = sqrt(imageSizePainting(1)^2+imageSizePainting(2)^2);
K = [focal 0 imageSizePainting(2)/2; 0 focal imageSizePainting(1)/2; 0 0 1];
R = CameraStruct(cNdx).R;
C = CameraStruct(cNdx).C;
P = K*R*[eye(3) -C];

% Get ridges&valleys and occlusion contours for viewpoint:
[lines_all,lines_rv,lines_occ] = meshLineDrawing(P,meshFileName,normalsFileName,holesFileName,imageSizePainting);

V1 = mean(double(lines_all)/255,3);
[V1pb,V1theta] = hysterisis(1-V1);

% Set inlier threshold:
inlierThresh = round(0.005*sqrt(imageSizePainting(1)^2+imageSizePainting(2)^2));

% $$$ map1 = (V2pb>0.05);
% $$$ map2 = (rand(size(map1))>0.75);

map1 = logical(zeros(size(V1pb,1),size(V1pb,2),Norient));
map2 = logical(zeros(size(V2pb,1),size(V2pb,2),Norient));
for i = 1:Norient
  map1(:,:,i) = (V1pb>0.05)&(V1theta==angBins(i));
  map2(:,:,i) = (V2pb>0.05)&(V2theta==angBins(i));
end

map3D = map1;
mapPainting = map2;
[score,xout,yout,isValid,tout,costMap] = denseMeasure(map3D,mapPainting,inlierThresh);

% Test 1: isValid touches only painting points:
foo = V2pb>0.05;
sum(~foo(isValid))

% Test 2: xout,yout only touch 3D points:
n = sub2ind(size(V1pb),yout(isValid),xout(isValid));
foo = V1pb>0.05;
sum(~foo(n))

% Test 3: xout,yout,tout only touch valid 3D map points:
n = sub2ind(size(map3D),yout(isValid),xout(isValid),tout(isValid));
sum(~map3D(n))

% $$$ tic; score = denseMeasure(map1,map2,inlierThresh); toc
% $$$ % $$$ score = denseMeasure(V1pb>0.05,V2pb>0.05,inlierThresh)
% $$$ 
% $$$ for i = 1:10
% $$$   score = denseMeasure(map1,map2,inlierThresh);
% $$$ end
