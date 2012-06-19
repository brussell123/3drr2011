function cost = matchingCost(P,X,theta,mapPainting,inlierThresh)
% Inputs:
% P - Camera matrix
% X - 3D points corresponding to dense edge points
% theta - Orientation indices for dense edge points
% mapPainting - MxNxK binary edge map for painting
% inlierThresh - Inlier threshold
% 
% Outputs:
% cost - Match cost

[M,N,K] = size(mapPainting);
D = size(X,2);

if size(X,1) < 4
  % Make 3D points homogeneous vectors:
  X = [X; ones(1,D)];
end

% Project 3D points:
x = project3D2D(P,X,[M N]);
% $$$ x = P*X;
% $$$ y = x(2,:)./x(3,:);
% $$$ x = x(1,:)./x(3,:);

% Get binary edge map for 3D model:
map3D = pointsToMap(x(1,:),x(2,:),theta,[M N],K);
% $$$ map3D = pointsToMap(x,y,theta,[M N],K);

% Get match score:
cost = denseMeasure(map3D,mapPainting,inlierThresh);
