function pball = filterSecondDerivative(img)

Norient = 8;
angBins = linspace(0,pi,Norient+1);
% Get edge orientation information:
N = 7;
sig = 1;
[xx,yy] = meshgrid(-N:N);
pball = zeros(size(img,1),size(img,2),Norient);
for i = 1:Norient
  tt = angBins(i)+pi/2;
  G = -exp(-(xx.^2+yy.^2)/2/sig^2).*((xx*cos(tt)+yy*sin(tt)).^2-sig^2)/sig^4;
  pball(:,:,i) = conv2(img,G,'same');
  pball(:,:,i) = pball(:,:,i)/sum(sum(max(G,0)));
end
% $$$ pball = max(0,pball);
