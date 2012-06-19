function [pb,theta] = hysterisis(img)
% Inputs:
% img - Line image
%
% Outputs:
% imgNonMax - Non-max suppressed line image

% $$$ img = foo;

Norient = 8;
angBins = linspace(0,pi,Norient+1);

% $$$ N = 7;
% $$$ sig = 2;
% $$$ [xx,yy] = meshgrid(-N:N);
% $$$ G2 = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(angBins(i))+yy*sin(angBins(i))).^2-sig^2)/sig^4;

% Get edge orientation information:
N = 7;
% $$$ sig1 = 4; sig2 = 2;
sig = 1;
[xx,yy] = meshgrid(-N:N);
pball = zeros(size(img,1),size(img,2),Norient);
for i = 1:Norient
  tt = angBins(i)+pi/2;
  G = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(tt)+yy*sin(tt)).^2-sig^2)/sig^4;
% $$$   G = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(angBins(i))+yy*sin(angBins(i))).^2-sig^2)/sig^4;
% $$$   G1 = exp(-(cos(angBins(i))*xx+sin(angBins(i))*yy).^2/2/sig1^2)/sig1/sqrt(2*pi); %G1=G1/sum(G1(:));
% $$$   G2 = exp(-(cos(angBins(i))*xx+sin(angBins(i))*yy).^2/2/sig2^2)/sig2/sqrt(2*pi); %G2=G2/sum(G2(:));
% $$$   G = G2-G1;
% $$$ % $$$   G = 2*G/sum(sum(G));
  pball(:,:,i) = conv2(img,G,'same');
  pball(:,:,i) = pball(:,:,i)/sum(sum(max(G,0)));
end
pball = max(0,pball);
% $$$ pball = pball.*repmat(img./(sum(pball,3)+eps),[1 1 Norient]);

% $$$ % Shift angBins:
% $$$ angBins = mod(angBins+pi/2,pi);

% $$$ % Get edge orientations:
% $$$ [ang,pball] = edgeOrientation(img);
% $$$ 
% $$$ % Assign edges to nearest orientation bin:
% $$$ maxo = zeros(size(ang));
% $$$ for i = 1:Norient+1
% $$$   maxo(:,:,i) = (ang-angBins(i)).^2;
% $$$ end
% $$$ [vv,maxo] = min(maxo,[],3);
% $$$ maxo(maxo==Norient+1) = 1;

% nonmax suppression and max over orientations
[unused,maxo] = max(pball,[],3);
pb = zeros(size(img));
theta = zeros(size(img));
r = 2.5;
for i = 1:Norient,
  mask = (maxo == i);
  a = fitparab(pball(:,:,i),r,r,angBins(i));
  pbi = nonmax(max(0,a),angBins(i));
  pb = max(pb,pbi.*mask);
  theta = theta.*~mask + angBins(i).*mask;
end
pb = max(0,min(1,pb));

% mask out 1-pixel border where nonmax suppression fails
pb(1,:) = 0;
pb(end,:) = 0;
pb(:,1) = 0;
pb(:,end) = 0;

% $$$ figure;
% $$$ imshow(img);
% $$$ figure;
% $$$ imshow(pb);

function pb = hysterisis_v2(pbgm)
% Inputs:
% pbgm
%
% Outputs:
% pb

% Parameters:
nthresh=100;
hmult=1/3;

% Apply hysteresis thresholding:
pb = zeros(size(pbgm));
thresh = linspace(1/nthresh,1-1/nthresh,nthresh);
for i = 1:nthresh,
  [r,c] = find(pbgm>=thresh(i));
  if numel(r)==0, continue; end
  b = bwselect(pbgm>hmult*thresh(i),c,r,8);
  pb = max(pb,b*thresh(i));
end


function pb = hysterisis_v3(img)
% Inputs:
% img - Line image
%
% Outputs:
% imgNonMax - Non-max suppressed line image

img = foo;

Norient = 8;
angBins = linspace(0,pi,Norient+1);

% $$$ N = 7;
% $$$ sig = 2;
% $$$ [xx,yy] = meshgrid(-N:N);
% $$$ G2 = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(angBins(i))+yy*sin(angBins(i))).^2-sig^2)/sig^4;

% Get edge orientation information:
N = 7;
% $$$ sig1 = 4; sig2 = 2;
sig = 1;
[xx,yy] = meshgrid(-N:N);
pball = zeros(size(img,1),size(img,2),Norient);
for i = 1:Norient
  tt = angBins(i)+pi/2;
  G = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(tt)+yy*sin(tt)).^2-sig^2)/sig^4;
% $$$   G = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(angBins(i))+yy*sin(angBins(i))).^2-sig^2)/sig^4;
% $$$   G1 = exp(-(cos(angBins(i))*xx+sin(angBins(i))*yy).^2/2/sig1^2)/sig1/sqrt(2*pi); %G1=G1/sum(G1(:));
% $$$   G2 = exp(-(cos(angBins(i))*xx+sin(angBins(i))*yy).^2/2/sig2^2)/sig2/sqrt(2*pi); %G2=G2/sum(G2(:));
% $$$   G = G2-G1;
% $$$ % $$$   G = 2*G/sum(sum(G));
  pball(:,:,i) = conv2(img,G,'same');
  pball(:,:,i) = pball(:,:,i)/sum(sum(max(G,0)));
end
pball = max(0,pball);
% $$$ pball = pball.*repmat(img./(sum(pball,3)+eps),[1 1 Norient]);

% $$$ % Shift angBins:
% $$$ angBins = mod(angBins+pi/2,pi);

% $$$ % Get edge orientations:
% $$$ [ang,pball] = edgeOrientation(img);
% $$$ 
% $$$ % Assign edges to nearest orientation bin:
% $$$ maxo = zeros(size(ang));
% $$$ for i = 1:Norient+1
% $$$   maxo(:,:,i) = (ang-angBins(i)).^2;
% $$$ end
% $$$ [vv,maxo] = min(maxo,[],3);
% $$$ maxo(maxo==Norient+1) = 1;

% nonmax suppression and max over orientations
[unused,maxo] = max(pball,[],3);
pb = zeros(size(img));
theta = zeros(size(img));
r = 2.5;
for i = 1:Norient,
  mask = (maxo == i);
  a = fitparab(pball(:,:,i),r,r,angBins(i));
  pbi = nonmax(max(0,a),angBins(i));
  pb = max(pb,pbi.*mask);
  theta = theta.*~mask + angBins(i).*mask;
end
pb = max(0,min(1,pb));

% mask out 1-pixel border where nonmax suppression fails
pb(1,:) = 0;
pb(end,:) = 0;
pb(:,1) = 0;
pb(:,end) = 0;

figure;
imshow(img);
figure;
imshow(pb);



figure;
for i = 1:Norient
  clf;
  imshow(pball(:,:,i));
  pause;
end

for r = [1 2 3 4 5]
  a = fitparab(pball(:,:,i),r,r,angBins(i));
  clf;
  imshow(a);
  pause;
end


pb = hysterisis(foo);
