function [n,xPainting,x3D] = getDenseInliers(P,Xdense,thetaNdxDense,mapPainting,inlierThresh)
% Inputs:
% P - Camera matrix
% Xdense - 3xD set of 3D points
% thetaNdxDense - 1xD set of edge orientation indices for 3D points
% mapPainting - MxNxK edge map for painting
% inlierThresh - Ransac inlier threshold
%
% Outputs:
% n - 1xS set of indices of inlier 3D points
% xPainting - 2xS set of inlier 2D painting points
% x3D - 2xS set of projected inlier 3D model points

[M,N,K] = size(mapPainting);

% Project dense points:
xp = project3D2D(P,Xdense,[M N]);

% Get edge map for projected 3D points:
[map3D,mapNdx] = pointsToMap(xp(1,:),xp(2,:),thetaNdxDense,[M N],K);

% Get inlier correspondences:
[junk,xout,yout,isValid,tout] = denseMeasure(map3D,mapPainting,inlierThresh);

% Painting points:
[yPainting,xPainting] = find(isValid);
xPainting = [xPainting(:) yPainting(:)]';

% 3D model points:
n = sub2ind(size(mapNdx),yout(isValid),xout(isValid),tout(isValid));
n = mapNdx(n);
x3D = project3D2D(P,Xdense(:,n),[M N]);
