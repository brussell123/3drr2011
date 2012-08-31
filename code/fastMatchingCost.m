function cost = fastMatchingCost(distMap,ndxMap,Nedges,P,X,theta,inlierThresh)
% Approximation to matching cost.
%
% Inputs:
% distMap
% ndxMap
% Nedges
% P
% X
% theta
% inlierThresh
%
% Outputs:
% cost

[M,N,K] = size(distMap);

% Project 3D points:
x = project3D2D(P,X,[M N]);
y = round(x(2,:));
x = round(x(1,:));

% Handle boundary conditions:
n = find((x>=1)&(x<=N)&(y>=1)&(y<=M));

cost = 0;
for i = 1:K
  j = find(theta(n)==i);
  if ~isempty(j)
    mm = distMap(:,:,i);
    nn = ndxMap(:,:,i);
    k = sub2ind(size(mm),y(n(j)),x(n(j)));
    cost = cost + sum(minAssign(mm(k),nn(k),Nedges(i),single(inlierThresh)));
  else
    cost = cost + inlierThresh*single(Nedges(i));
  end
end
cost = cost/single(sum(Nedges));


return;

cost = 0;
N = 0;
for i = 1:K
  j = find(theta(n)==i);
  nn = squeeze(ndxMap(:,:,i));
  if ~isempty(j)
    mm = squeeze(distMap(:,:,i));
    k = int32(sub2ind(size(mm),y(n(j)),x(n(j))));
    cc = minAssign(mm,nn,k,single(inlierThresh));
    mm = (mm==0);
    cost = cost + sum(sum(mm.*cc));
    N = N+sum(sum(mm));
  end
end
cost = cost/N;


return;

% $$$ [M,N,K] = size(distMap);
% $$$ 
% $$$ % Project 3D points:
% $$$ x = project3D2D(P,X,[M N]);
% $$$ y = round(x(2,:));
% $$$ x = round(x(1,:));
% $$$ 
% $$$ % Handle boundary conditions:
% $$$ n = find((x>=1)&(x<=N)&(y>=1)&(y<=M));
% $$$ 
% $$$ cost = inlierThresh*(length(x)-length(n));
% $$$ for i = 1:K
% $$$   j = find(theta(n)==i);
% $$$   if ~isempty(j)
% $$$     mm = squeeze(distMap(:,:,i));
% $$$     cost = cost + sum(mm(sub2ind(size(mm),y(n(j)),x(n(j)))));
% $$$   end
% $$$ end
% $$$ cost = cost/length(x);
