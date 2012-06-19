function [V,x,t,isRV,XX] = meshFeatures(P,vertices,faces,meshFileName,normalsFileName,holesFileName,imageSize)
% Inputs:
% P
% vertices
% faces
% meshFileName
% normalsFileName
% holesFileName
% imageSize
%
% Outputs:
% V - Binary map
% x - 2xN points
% t - 1xN edge orientation indices
% isRV - 1xN indicates if point is ridges&valley (not occlusion)
% X - 3xN 3D points

% Parameters:
Norient = 8; % Number of edge orientations

% Get edge orientation bins:
angBins = linspace(0,pi,Norient+1);

% Get ridges&valleys and occlusion contours for viewpoint:
[lines_all,lines_rv,lines_occ] = meshLineDrawing(P,meshFileName,normalsFileName,holesFileName,imageSize);
lines_rv = mean(double(lines_rv),3)/255;
lines_occ = mean(double(lines_occ),3)/255;

% Get depth values:
[K,R,C] = decomposeP(P);
[gx,gy] = meshgrid(1:imageSize(2),1:imageSize(1));
[X,isValid,faceNdx] = getCorrespondences3d2d_v3(vertices,faces,single(P),[gx(:) gy(:)]',imageSize);
isValid = reshape(isValid,[imageSize(1) imageSize(2)]);
faceNdx = reshape(faceNdx,[imageSize(1) imageSize(2)]);
X = reshape(X',[imageSize(1) imageSize(2) 3]);
depth = sqrt(sum((X-reshape(repmat(C',imageSize(1)*imageSize(2),1),[imageSize(1) imageSize(2) 3])).^2,3));

% Get depth discontinuities:
depth(~isValid) = 2*max(depth(:));
imgCanny = edge(depth,'canny');

% Keep lines that agree with output of line drawing software:
imgCanny = imgCanny&(lines_occ<0.95);

% Remove small connected components:
L = bwlabel(imgCanny);
h = hist(L(:),0:max(L(:)));
h = h(2:end);
L(ismember(L,find(h<=10))) = 0;
imgOcc = (L>0);

% $$$ figure;
% $$$ imagesc(imgOcc);

% $$$ % Remove small connected component in RV:
% $$$ L = bwlabel(lines_rv<0.95);
% $$$ h = hist(L(:),0:max(L(:)));
% $$$ h = h(2:end);
% $$$ L(ismember(L,find(h<=15))) = 0;
% $$$ imgRV = (L>0);

% $$$ figure;
% $$$ imagesc(imgRV);

% Keep only valid RV responses:
resRV = 1-lines_rv;
% $$$ resRV(~imgRV) = 0;

% Perform nonmax suppression:
h = hysterisis(resRV);
imgRV = (h>0.25);

% $$$ figure;
% $$$ imagesc(imgRV>0.25);

% Remove small connected component in RV:
L = bwlabel(imgRV);
h = hist(L(:),0:max(L(:)));
h = h(2:end);
L(ismember(L,find(h<=10))) = 0;
imgRV = (L>0);

% Remove duplicate edges in RV and occlusion:
d = bwdist(imgRV,'euclidean');
imgOcc = ((d.*imgOcc)>3)&imgOcc;

% $$$ figure;
% $$$ imagesc(imgOcc | imgRV);

% Get binary map:
V = (imgOcc | imgRV);
imgOcc = logical(V-imgRV);

% Get orientations:
pball = filterSecondDerivative(double(V));
[junk,thetaNdx] = max(pball,[],3);

% $$$ figure;
% $$$ for i = 1:8
% $$$   clf;
% $$$   imshow(V&(thetaNdx==i));
% $$$   ginput(1);
% $$$ end

% Get points and orientations:
[yRV,xRV] = find(imgRV);
[yOcc,xOcc] = find(imgOcc);
tRV = thetaNdx(imgRV);
tOcc = thetaNdx(imgOcc);

% Accumulate points and set type:
x = [xRV yRV; xOcc yOcc]';
t = [tRV; tOcc]';
isRV = logical([ones(1,length(xRV)) zeros(1,length(xOcc))]);

% $$$ figure;
% $$$ for i = 1:8
% $$$   clf;
% $$$   plot(x(1,t==i),x(2,t==i),'r.');
% $$$   axis([1 imageSize(2) 1 imageSize(1)]);
% $$$   axis ij;
% $$$   ginput(1);
% $$$ end
% $$$ 
% $$$ figure;
% $$$ plot(x(1,isRV),x(2,isRV),'r.');
% $$$ axis ij;

% Find which points land outside valid region:
nUpdate = find(~isRV | ~isValid(sub2ind(size(isValid),x(2,:),x(1,:))));

% Update position of points:
neighborSearch = int32(2);
[xx1,yy1,vv1] = updateDepths(int32(x(1,nUpdate)),int32(x(2,nUpdate)),depth,isValid,neighborSearch);
x(1,nUpdate) = double(xx1);
x(2,nUpdate) = double(yy1);
x(:,nUpdate(~vv1)) = [];
t(nUpdate(~vv1)) = [];
isRV(nUpdate(~vv1)) = [];

% $$$ figure;
% $$$ imshow(V);
% $$$ hold on;
% $$$ plot(x(1,:),x(2,:),'r.');
% $$$ quiver(x(1,:),x(2,:),cos(angBins(t)),sin(angBins(t)),0.5,'b')

% Get 3D points:
XX = zeros(3,size(x,2));
XX(1,:) = X(sub2ind(size(isValid),x(2,:),x(1,:)));
XX(2,:) = X(sub2ind(size(isValid),x(2,:),x(1,:))+prod(size(isValid)));
XX(3,:) = X(sub2ind(size(isValid),x(2,:),x(1,:))+2*prod(size(isValid)));

% $$$ figure;
% $$$ plot3(XX(1,:),XX(2,:),XX(3,:),'.');
% $$$ axis equal;

% Make sure image points are unique:
[junk,j] = unique(x','rows');
x = x(:,j);
t = t(j);
isRV = isRV(j);
XX = XX(:,j);




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
meshColoredFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_colored.ply';

% Painting 03:
PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting03_down.jpg';
NN_MAT = '~/work/Archaeology/Data/SynthesizeViewpoints/NN/Painting03_NN.mat';
knn = 1;

% Read painting:
imgPainting = imread(PAINTING_FNAME);
if size(imgPainting,3) ~= 3
  imgPainting = repmat(imgPainting,[1 1 3]);
end
imageSize = size(imgPainting);

% Get set of sampled viewpoints:
load /Users/brussell/work/Archaeology/Data/SynthesizeViewpoints/CameraStructVisible_v3.mat;

% Get gist nearest neighbors:
NN = load(NN_MAT);

% Get initial viewpoint from gist:
P = getGistViewpoint(CameraStruct,NN.n(knn),imageSize);

% Read mesh:
[vertices,faces] = mexReadPly(meshFileName);

% Get 3D model features:
% $$$ [V1,V1pb,V1theta,X,x,theatNdx,pointTypes,theta] = meshFeatures(P,vertices,faces,meshFileName,normalsFileName,holesFileName,imageSize);

[V,x,t,isRV,X] = meshFeatures(P,vertices,faces,meshFileName,normalsFileName,holesFileName,imageSize);
