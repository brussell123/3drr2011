function n = sampleEdges_v2(x,nsamp)

% Randomly sample points:
N = size(x,2);
rp = randperm(N);
n = rp(1:min(3*nsamp,N));
x = x(:,n);

% Make points evenly spaced:
for i = 1:length(n)-nsamp
  xx = single(x);
  [aa,bb,vv,nn] = fastNN(xx,xx);
  [aa,j] = min(vv);
  x(:,nn(j)) = [];
  n(nn(j)) = [];
end

return;

% $$$ function [x,y,t,n] = sampleEdges_v2(varargin)
% $$$ % [x,y,t] = sampleEdges(V,Vtheta,nsamp)
% $$$ % or
% $$$ % [x,y,t,n] = sampleEdges(x,y,t,nsamp)
% $$$ %
% $$$ % V - Binary map
% $$$ 
% $$$ if nargin == 3
% $$$   V = varargin{1};
% $$$   Vtheta = varargin{2};
% $$$   nsamp = varargin{3};
% $$$   
% $$$   V = logical(V);
% $$$   [y,x] = find(V);
% $$$   t = Vtheta(V);
% $$$ elseif nargin == 4
% $$$   x = varargin{1};
% $$$   y = varargin{2};
% $$$   t = varargin{3};
% $$$   nsamp = varargin{4};
% $$$ else
% $$$   error('Invalid number of arguments');
% $$$   return;
% $$$ end
% $$$ 
% $$$ % Randomly sample points:
% $$$ N = length(x);
% $$$ rp = randperm(N);
% $$$ n = rp(1:min(3*nsamp,N));
% $$$ x = x(n);
% $$$ y = y(n);
% $$$ t = t(n);
% $$$ 
% $$$ % Make points evenly spaced:
% $$$ for i = 1:length(n)-nsamp
% $$$   xx = single([x y])';
% $$$   [aa,bb,vv,nn] = fastNN(xx,xx);
% $$$   [aa,j] = min(vv);
% $$$   x(nn(j)) = [];
% $$$   y(nn(j)) = [];
% $$$   t(nn(j)) = [];
% $$$   n(nn(j)) = [];
% $$$ end
