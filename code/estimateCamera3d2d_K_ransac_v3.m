function [P,cost] = estimateCamera3d2d_K_ransac_v3(K,X,x,inlierThresh,NpointsAlg,Xdense,theta,mapPainting,Niter,P_start,cost_start)
% Estimate camera matrix given calibration matrix K and 3D<->2D
% correspondences.

% Parameters:
if nargin < 9
  Niter = 1000;
end

if nargin < 5
  NpointsAlg = 4; % Number of points to solve for (3 or 4)
end
if nargin < 10
  P = [];
else
  P = P_start;
end  
if nargin < 11
  cost = inf;
else
  cost = cost_start;
end

N = size(x,2);

if size(X,1) < 4
  X = [X; ones(1,N)];
end
if size(x,1) < 3
  x = [x; ones(1,N)];
end
if size(Xdense,1) < 4
  Xdense = [Xdense; ones(1,size(Xdense,2))];
end

for i = 1:Niter
  display(sprintf('%d out of %d: %f',i,Niter,cost));

  % Get random set of points:
  rp = randperm(N);
  n = rp(1:NpointsAlg);

  % Make sure image and world points are unique:
  if size(unique(x(:,n)','rows'),1) ~= NpointsAlg
    continue;
  end
  if size(unique(X(:,n)','rows'),1) ~= NpointsAlg
    continue;
  end

  % Get camera matrix proposal:
  switch NpointsAlg
   case 3
    allP = fast_estimate_RC_v2(K,x(:,n),X(:,n));
   case 4
    % Transform and center image points:
    xx = x(1:2,n)-repmat([K(7); K(8)],1,NpointsAlg);
    [all_f,all_R,all_t] = P4Pf(double(xx),double(X(1:3,n)));
    allP = zeros(3,4,length(all_f));
    for j = 1:length(all_f)
      allP(:,:,j) = [all_f(j) 0 K(7); 0 all_f(j) K(8); 0 0 1]*[squeeze(all_R(:,:,j)) all_t(:,j)];
    end
   otherwise
    error('Invalid NpointsAlg');
  end
  
  if ~isempty(allP)
    for j = 1:size(allP,3)
      Pi = squeeze(allP(:,:,j));

      % Score camera matrix proposal:
      cost_i = matchingCost(Pi,Xdense,theta,mapPainting,inlierThresh);
      if cost_i < cost
        cost = cost_i;
        P = Pi;
      end
    end
  end
end

display(sprintf('Matching cost: %f',cost));
