function [V,x,t] = paintingFeatures_v3(imgPainting,BIN_SEGMENT,CACHE_DIR)
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

[gPb,theta,gPb_full] = RunGPB(imgPainting,BIN_SEGMENT,CACHE_DIR);

V = zeros(size(gPb));
Vt = zeros(size(gPb));
for i = 1:Nang
  j = mod([i-1 i i+1]-1,Nang)+1;
  nn = (gPb>=threshResponse)&(ismember(theta,j));
  mm = (gPb>=threshResponse)&(theta==i);
  
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
