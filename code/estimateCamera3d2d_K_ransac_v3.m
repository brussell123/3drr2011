function [P,cost] = estimateCamera3d2d_K_ransac_v3(K,X,x,inlierThresh,NpointsAlg,Xdense,theta,mapPainting,Niter)
% Estimate camera matrix given calibration matrix K and 3D<->2D
% correspondences.

% Parameters:
if nargin < 9
  Niter = 1000;
end

if nargin < 5
  NpointsAlg = 4; % Number of points to solve for (3 or 4)
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

% Compute distance transform of painting edges:
Nedges = zeros(1,size(mapPainting,3),'int32');
for i = 1:size(mapPainting,3)
  mm = squeeze(mapPainting(:,:,i));
  Nedges(i) = sum(sum(mm));
  [distMap(:,:,i),nn] = bwdist(mm,'euclidean');
  map = zeros(size(mm));
  mm = find(mm);
  map(mm) = 1:length(mm);
  ndxMap(:,:,i) = map(nn);
end
distMap = single(distMap);
ndxMap = int32(ndxMap);

% $$$ for i = 1:size(mapPainting,3)
% $$$   [distMap(:,:,i),ndxMap(:,:,i)] = bwdist(squeeze(mapPainting(:,:,i)),'euclidean');
% $$$ end
% $$$ distMap = single(distMap);
% $$$ ndxMap = int32(ndxMap);

P = [];
cost = inf;
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
      cost_i = fastMatchingCost(distMap,ndxMap,Nedges,Pi,Xdense,theta,inlierThresh);
% $$$       cost_i = matchingCost(Pi,Xdense,theta,mapPainting,inlierThresh);

      if cost_i < cost
        cost = cost_i;
        P = Pi;
      end
    end
  end
end

% Get final matching cost:
cost = matchingCost(P,Xdense,theta,mapPainting,inlierThresh);

display(sprintf('Matching cost: %f',cost));
