function [V,x,t] = paintingFeatures_v3(gpb_fname)
% Inputs:
% gpb_fname
%
% Outputs:
% V - Binary map
% x - 2xN points
% t - 1xN edge orientation indices

% Parameters:
Nang = 8; % Number of gpb orientation angles
threshResponse = 0.05; % gpb response threshold

% $$$ gpb_fname = GPB_FNAME;

ss = load(gpb_fname);

V = zeros(size(ss.gPb));
Vt = zeros(size(ss.gPb));
for i = 1:Nang
  j = mod([i-1 i i+1]-1,Nang)+1;
  nn = (ss.gPb>=threshResponse)&(ismember(ss.theta,j));
  mm = (ss.gPb>=threshResponse)&(ss.theta==i);
  
  L = bwlabel(nn);
  h = hist(L(:),0:max(L(:)));
  h = h(2:end);
  L(ismember(L,find(h<=10))) = 0;
  V((L>0)&mm) = 1;
  Vt((L>0)&mm) = i;
  
% $$$   clf
% $$$   imshow(nn);
% $$$   ginput(1);
end

[y,x] = find(V);
x = [x y]';
t = mod(Vt(find(V))+3,Nang)+1;
