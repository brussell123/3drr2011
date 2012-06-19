function OverlappingViews = FindOverlappingViews(CameraStruct,meshname,CACHE_DIR)

% Parameters:
imageSize = [360 284];

if ~exist(fullfile(CACHE_DIR,'OverlappingViews.mat'),'file')
  % Read mesh vertices and faces:
  X = mexReadPly(meshname);
  
  % Get all camera matrices:
  P = zeros(3,4,length(CameraStruct));
  for i = 1:length(CameraStruct)
    P(:,:,i) = [1 0 -178; 0 1 0; 0 0 1]*CameraStruct(i).K*[1 0 0; 0 -1 0; 0 0 -1]*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];
  end
  
  OverlappingViews = FindOverlappingViews_helper(P,X,imageSize);
  
  save(fullfile(CACHE_DIR,'OverlappingViews.mat'),'OverlappingViews');
else
  load(fullfile(CACHE_DIR,'OverlappingViews.mat'));
end
  

return;

function ProbInlier = FindOverlappingViews_helper(P,X,imageSize,CameraStruct)
% $$$ function [ProbInlier,Ninlier] = FindOverlappingViews(P,X,imageSize,CameraStruct)
% Inputs:
% P - Sorted camera matrices
% X - 3D scene points
% imageSize
%
% Outputs:
% ProbInlier - Percentage of inlier points.
% Ninlier - Number of inlier points.

% Parameters:
threshInlier = 0.6;
max3Dpoints = 1e6; % Restrict number of 3D points (for efficiency)

% $$$ if size(X,2)>max3Dpoints
% $$$   rp = randperm(size(X,2));
% $$$   rp = rp(1:max3Dpoints);
% $$$   X = X(:,rp);
% $$$ end

for i = 1:size(P,3)
  [a,b,C(:,i)] = decomposeP(squeeze(P(:,:,i)));
end

KNN = 100;

% $$$ keyboard;
% $$$ i = 3505;
% $$$ i = 991;

ProbInlier = logical(sparse(size(P,3),size(P,3)));
% $$$ ProbInlier = zeros(size(P,3),size(P,3));
% $$$ Ninlier = zeros(size(P,3),size(P,3));
for i = 1:size(P,3)
  display(sprintf('%d out of %d',i,size(P,3)));
  
  Pgt = squeeze(P(:,:,i));

  % Get k-nn cameras to current camera:
  d = sum((C(:,i)*ones(1,size(C,2))-C).^2,1);
  [v,n] = sort(d);
  n = n(1:KNN);
  Pn = P(:,:,n);
  
  tic;
  pp = evaluateViewpoint(Pgt,Pn,X,imageSize,threshInlier);
% $$$   pp = evaluateViewpoint(Pgt,P,X,imageSize,threshInlier);
  toc
  ProbInlier(i,n(pp>=threshInlier)) = 1;
% $$$   ProbInlier(i,find(pp>=threshInlier)) = 1;
% $$$   [ProbInlier(i,:),Ninlier(i,:)] = evaluateViewpoint(Pgt,P,X,imageSize,threshInlier);
end


return;

% $$$ % PLY file:
% $$$ plyFile = '/Users/brussell/work/Archaeology/Data/3Dmodel/pompeii_pmvs_half_points_only.ply';

OverlappingViews = FindOverlappingViews(CameraStruct,meshColoredFileName);
