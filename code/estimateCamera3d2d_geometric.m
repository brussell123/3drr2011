function P = estimateCamera3d2d_geometric(P,X,x,doNormalization)

if nargin < 4
  doNormalization = 0;
end

if size(X,2) ~= size(x,2)
  error('X and x must have same number of columns');
  return;
end

N = size(x,2);

if size(x,1) < 3
  x = [x; ones(1,N)];
else
  x = [x(1,:)./x(3,:); x(2,:)./x(3,:); ones(1,N)];
end

if size(X,1) < 4
  X = [X; ones(1,N)];
else
  X = [X(1,:)./X(4,:); X(2,:)./X(4,:); X(3,:)./X(4,:); ones(1,N)];
end

if doNormalization
  % Normalize 2D points:
  mu = mean(x(1:2,:),2);
  sc = mean(sum((x(1:2,:)-repmat(mu,1,N)).^2,1).^0.5);
  T = [sqrt(2)/sc 0 -mu(1)*sqrt(2)/sc; 0 sqrt(2)/sc -mu(2)*sqrt(2)/sc; 0 0 1];
% $$$ T = [1 0 0; 0 -1 0; 0 0 1]*T;
  x = T*x;

  % Normalize 3D points:
  mu = mean(X(1:3,:),2);
  sc = mean(sum((X(1:3,:)-repmat(mu,1,N)).^2,1).^0.5);
  U = [sqrt(3)/sc 0 0 -mu(1)*sqrt(3)/sc; 0 sqrt(3)/sc 0 -mu(2)*sqrt(3)/sc; 0 0 sqrt(3)/sc -mu(3)*sqrt(3)/sc; 0 0 0 1];
  X = U*X;

  % Normalize P:
  P = single(T*P*inv(U));
end

% Decompose estimated camera matrix:
[K,R,C] = decomposeP(P);

% $$$ ff = mean([K(1) K(5)]);
% $$$ K(1) = ff;
% $$$ K(5) = ff;
% $$$ K(4) = 0;
% $$$ P = K*R*[eye(3) -C];
% $$$ return;

% Get rotation parameters:
% $$$ [u,s,v] = svd(R-eye(3));
% $$$ vv = v(:,3);
vv = null(R-eye(3));
% $$$ S = [0 -vv(3) vv(2); vv(3) 0 -vv(1); -vv(2) vv(1) 0];
vvhat = [R(3,2)-R(2,3) R(1,3)-R(3,1) R(2,1)-R(1,2)]';
ang = atan2(vv'*vvhat,trace(R)-1);
w = ang*vv;

% $$$ keyboard;

% Minimize geometric error:
% $$$ params = double([max([K(1) K(5)]) K(7) K(8) w' C']);
params = double([mean([K(1) K(5)]) K(7) K(8) w' C']);
options = optimset('GradObj','on','Hessian','on','Display','off');
% $$$ options = optimset('GradObj','on','Hessian','on');
% $$$ options = optimset('GradObj','on','Hessian','on','MaxIter',1000,'PlotFcns',@optimplotfval);
paramsOpt = fminunc(@(p)costFunctionCameraResectioning(p,double(X(1,:)),double(X(2,:)),double(X(3,:)),double(x(1,:)),double(x(2,:))),params,options);
% $$$ paramsOpt = fminunc(@(p)costFunctionCameraResectioning(p,X(1,:),X(2,:),X(3,:),x(1,:),x(2,:)),params,options);

% Get camera matrix:
wOpt = paramsOpt(4:6);
angOpt = sqrt(sum(wOpt.^2));
nOpt = wOpt/angOpt;
N = [0 -nOpt(3) nOpt(2); nOpt(3) 0 -nOpt(1); -nOpt(2) nOpt(1) 0];
P = [paramsOpt(1) 0 paramsOpt(2); 0 paramsOpt(1) paramsOpt(3); 0 0 1]*(eye(3) + sin(angOpt)*N + (1-cos(angOpt))*N*N)*[eye(3) -paramsOpt(7:9)'];

if doNormalization
  P = single(inv(T)*P*U);
end
