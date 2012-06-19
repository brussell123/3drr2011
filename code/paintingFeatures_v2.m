function [Vnew,x,t] = paintingFeatures_v2(V2,imgPainting)
% Inputs:
% V2 - gPB response map
% imgPainting - Painting
%
% Outputs:
% V - Binary map
% x - 2xN points
% t - 1xN edge orientation indices

% $$$ figure;
% $$$ imagesc(V2);
% $$$ figure;
% $$$ imagesc(V2>0.1);

% Remove small connected components:
V = (V2>0.1);
L = bwlabel(V);
h = hist(L(:),0:max(L(:)));
h = h(2:end);
L(ismember(L,find(h<=10))) = 0;
Vnew = (L>0);

img_2nd = filterSecondDerivative(double(Vnew));
[img_2nd,theta] = max(img_2nd,[],3);

% $$$ figure;
% $$$ for i = 1:8
% $$$   clf;
% $$$   imshow(Vnew & (theta==i));
% $$$   ginput(1);
% $$$ end

[y,x] = find(Vnew);
x = [x y]';
t = theta(find(Vnew));

Norient = 8; % Number of edge orientations
angBins = linspace(0,pi,Norient+1);

% $$$ figure;
% $$$ imshow(Vnew);
% $$$ hold on;
% $$$ plot(x(1,:),x(2,:),'r.');
% $$$ quiver(x(1,:),x(2,:),cos(angBins(t)),sin(angBins(t)),0.5,'b')


return;

% Parameters:
cc = 0.01;
minLen = 0.025;
Norient = 8;
do_display = 0;

if size(imgPainting,3)==3
  % Get HSV values for painting:
  [hh,ss,V] = rgb2hsv(imgPainting);
else
  V = imgPainting;
end

% Local contrast normalization:
foo = medfilt2(V,[9 9]);
imgNorm = 1-V./(foo+cc);

if do_display
  figure;
  imshow(imgNorm);
end

% $$$ % Get orientations:
% $$$ img_2nd = filterSecondDerivative(imgNorm);
% $$$ [img_2nd,ori] = max(img_2nd,[],3);

minLen = minLen*sqrt(size(imgPainting,1)^2+size(imgPainting,2)^2);
[lines,pBlackPB_filtered] = largeLines(imgNorm,minLen);

if do_display
  figure;
  imshow(pBlackPB_filtered);
  hold on;
  plot(lines(:, [1 2])', lines(:, [3 4])','LineWidth',3);
end

% Combine gPB with long lines:
V2 = 1-min(1,1-V2+pBlackPB_filtered);

figure;
imshow(V2>0.05);



V2 = 1-V2;

V2pb = 1-V2;
img_2nd = filterSecondDerivative(V2pb);
[img_2nd,ori] = max(img_2nd,[],3);
angBins = linspace(0,pi,Norient+1);
V2theta = angBins(ori);

return;


addpath ~/work/Archaeology/BundlerToolbox_v03;
addpath ./sc_demo;
addpath ~/work/Archaeology/MeshCode/ToolboxCopy;
addpath ~/work/Archaeology/MeshCode;
addpath ~/work/MatlabLibraries/BerkeleyPB;
addpath ~/work/Archaeology/MeshCode/EstimateCamera;

% Painting 03:
PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting03_down.jpg';
fname2 = '~/Desktop/FOO/globalPb/img/gpb_painting_03.bmp';

% Read painting:
imgPainting = imread(PAINTING_FNAME);
imageSize = size(imgPainting);

% Get painting PB edges:
V2 = imread(fname2);
V2 = mean(double(V2),3)/255;

[V,x,t] = paintingFeatures_v2(V2,imgPainting);

figure;
imshow(V);

