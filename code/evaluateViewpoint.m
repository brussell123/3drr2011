function [ProbInlier,Ninlier] = evaluateViewpoint(Pgt,P,X,imageSize,Ninliers,threshInlier)
% Inputs:
% Pgt - Ground truth camera matrix
% P - Target camera matrices
% X - 3D scene points
% imageSize
%
% Outputs:
% Ninlier - Percentage of inliers for each target camera

% Parameters:
if nargin < 6
% $$$   threshInlier = 0.1; % Inlier threshold for a point (in image percentage)
    threshInlier = 0.05;
end

Npts = 100000; % Max number of 3D points to use (for efficiency)
doDisplay = 0;

% Convert inlier threshold to pixels:
threshInlier = threshInlier*max(imageSize);
threshInlier = threshInlier^2;

% Make sure 3D scene points are homogeneous vectors:
if size(X,1) < 4
  X = [X; ones(1,size(X,2))];
end

% Project points using ground truth camera:
xgt = Pgt*X;

% Get points in front of camera:
dgt = det(Pgt(:,1:3))*xgt(3,:);

% Get points lying inside image plane:
xgt = [xgt(1,:)./xgt(3,:); xgt(2,:)./xgt(3,:)];
nInside = find((xgt(1,:)>=1)&(xgt(1,:)<=imageSize(2))&(xgt(2,:)>=1)&(xgt(2,:)<=imageSize(1))&(dgt>0));

% Keep subset of 3D points (for efficiency):
if length(nInside)>Npts
  rp = randperm(length(nInside));
  rp = rp(1:Npts);
  nInside = nInside(rp);
end

xgtInside = xgt(:,nInside);
Xinside = X(:,nInside);
ProbInlier = zeros(1,size(P,3));
Ninlier = zeros(1,size(P,3));
for i = 1:size(P,3)
% $$$   display(sprintf('%d out of %d',i,size(P,3)));

  Pi = squeeze(P(:,:,i));
  
  % Project valid ground truth points using target camera:
% $$$   x = Pi*Xinside;
  x3 = Pi(3,:)*Xinside;
  dd = det(Pi(:,1:3))*x3;

  n = (dd>0);
  if sum(n)>=(Ninliers*size(Xinside,2)) %any(n)
    % Compute distance between valid projected ground truth points and
    % projected target points:
    x1 = Pi(1,:)*Xinside;
    x2 = Pi(2,:)*Xinside;
    x1 = x1(n)./x3(n);
    x2 = x2(n)./x3(n);

    d = (x1-xgtInside(1,n)).^2 + (x2-xgtInside(2,n)).^2;
    
% $$$     d = sum((x-xgtInside(:,n)).^2,1);
% $$$     d(dd<=0) = inf;

    Ninlier(i) = sum(d<=threshInlier);
    ProbInlier(i) = Ninlier(i)/(size(Xinside,2)+eps);
  end
  
  if doDisplay && (mod(i,10)==0)
    clf;
    plot(Ninlier);
% $$$     plot(Ninlier/size(Xinside,2));
    [vv,nn] = max(Ninlier);
    title(nn);
    drawnow;
  end
end

return;

addpath ~/work/MatlabLibraries/BundlerToolbox;
addpath ~/work/Archaeology/FlyThrough/OpenGL;
addpath ~/work/Archaeology/TextureMesh;


% PLY file:
plyFile = '/data/public_html/russell/Archaeology/3Dmodel/pompeii_pmvs_half_points_only.ply';

% Read mesh vertices and faces:
vertices = mexReadPly(plyFile);

imageSize = [360 284];

% Get all camera matrices:
P = zeros(3,4,length(CameraStruct));
for i = 1:length(CameraStruct)
  P(:,:,i) = [1 0 -178; 0 1 0; 0 0 1]*CameraStruct(i).K*[1 0 0; 0 -1 0; 0 0 -1]*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];
end

% Get ground truth camera matrix:
foo = load('~/work/Archaeology/TextureMesh/OutHandAlign/painting02_02.mat');
Pgt = [0.5 0 0; 0 0.5 0; 0 0 1]*foo.P;




% $$$ % Debugging....
% $$$ pp = CameraStruct(i).K*[1 0 0; 0 1 0; 0 0 -1]*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];
% $$$ pp = CameraStruct(i).K*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];
% $$$ 
% $$$ rp = randperm(size(Xinside,2));
% $$$ rp = rp(1:10000);
% $$$ figure;
% $$$ plot3(Xinside(1,rp),Xinside(2,rp),Xinside(3,rp),'r.');
% $$$ axis equal;
