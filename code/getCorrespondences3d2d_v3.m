function [X,isValid,faceNdx] = getCorrespondences3d2d_v3(vertices,faces,P,x,imageSize,Nclusters)
% Inputs:
% vertices
% faces
% P
% x - Desired 2D pixels that we want 3D locations of
% imageSize
%
% Outputs:
% X

[X,isValid,faceNdx] = getCorrespondences3d2d_v2_helper(vertices,faces,P,x,imageSize);

return;

% Parameters:
padding = 5;

if nargin < 6
  Nclusters = min(50,ceil(size(x,2)/50));
end
N = size(x,2);

% Perform clustering on line drawing points (for speed):
% $$$ Z = linkage([xLines yLines]);
if Nclusters > 1
  nClusters = kmeans(x',Nclusters,'emptyaction','singleton');
else
  nClusters = ones(1,N);
end

X = zeros(3,N);
isValid = logical(zeros(1,N));
for i = 1:Nclusters
  display(sprintf('%d out of %d',i,Nclusters)); tic;
  
  % Get cluster points:
  xx = x(:,nClusters==i);

  if ~isempty(xx)
    % Get bounding box around points (and add padding):
    bb = [min(xx,[],2)-padding max(xx,[],2)+padding];
    bb = [bb(1,1) bb(1,2) bb(1,2) bb(1,1); bb(2,1) bb(2,1) bb(2,2) bb(2,2)];
    
    % Get subset of mesh:
    [verticesSub,facesSub] = getSubsetMesh(vertices,faces,P,bb,imageSize);
    
    % Get 3D points:
    [X_i,isValid_i] = getCorrespondences3d2d_v2_helper(verticesSub,facesSub,P,xx,imageSize);
    X(:,nClusters==i) = X_i;
    isValid(nClusters==i) = isValid_i;
  end
  toc
end

  
  
function [X,isValid,faceNdx] = getCorrespondences3d2d_v2_helper(vertices,faces,P,x,imageSize)

% Make 2D coordinates zero-based:
% $$$ x = x-1;
if size(x,1) < 3
  x = [x; ones(1,size(x,2))];
end

% Decompose camera matrix:
[K,R,C] = decomposeP(P);

% Assume principal point is in the center of the image:
if nargin < 5
  imageSize = [2*K(8) 2*K(7)];
end

% Convert to OpenGL image coordinates:
x = image2openglcoordinates(x,imageSize);
x(2,:) = x(2,:)+1;

% Get 3D ray direction from 2D points:
D = P(:,1:3)\x;

[X,isValid,faceNdx] = rayTrace(D,C,vertices,faces);
% $$$ [aa,bb,cc,normals,lambda_num,Cu,Cv,bnu,bnv,cnu,cnv,isValid] = rayTrace(D,C,vertices,faces);

return;

% Inputs:
% D - 3xM matrix of direction vectors (single)
% C - 3x1 vector for camera center (single)
% vertices - 3xN matrix of vertices (single)
% faces - 3xK matrix of triangle face indices (int32)
%
% Outputs:
% X - 3xM matrix of 3D points that intersects the mesh (single)
% isValid - 1xM vector that indicates whether 3D point is valid intersection (logic)

% Pre-compute (for speed):
aa = vertices(:,faces(1,:))-vertices(:,faces(3,:));
bb = vertices(:,faces(2,:))-vertices(:,faces(3,:));
cc = vertices(:,faces(3,:));
Cexpand = repmat(C,1,size(faces,2));

% Get normal vector for each face:
% $$$ normals = b CROSS a;
normals = [aa(3,:).*bb(2,:)-aa(2,:).*bb(3,:); ...
           aa(1,:).*bb(3,:)-aa(3,:).*bb(1,:); ...
           aa(2,:).*bb(1,:)-aa(1,:).*bb(2,:)];

% Pre-compute numerator for lambda (for speed):
lambda_num = -sum(normals.*(Cexpand-cc));

% Get dominant axes:
dom = 3*ones(1,size(normals,2));
dom((abs(normals(1,:))>abs(normals(2,:)))&(abs(normals(1,:))>abs(normals(3,:)))) = 1;
dom((abs(normals(2,:))>abs(normals(1,:)))&(abs(normals(2,:))>abs(normals(3,:)))) = 2;
Uaxis = mod(dom,3)+1;
Vaxis = mod(dom+1,3)+1;

Cu = C(Uaxis)';
Cv = C(Vaxis)';

% Get Barycentric variables:
bu = aa(3,:);
bu(Uaxis==1) = aa(1,Uaxis==1);
bu(Uaxis==2) = aa(2,Uaxis==2);
bv = aa(3,:);
bv(Vaxis==1) = aa(1,Vaxis==1);
bv(Vaxis==2) = aa(2,Vaxis==2);
cu = bb(3,:);
cu(Uaxis==1) = bb(1,Uaxis==1);
cu(Uaxis==2) = bb(2,Uaxis==2);
cv = bb(3,:);
cv(Vaxis==1) = bb(1,Vaxis==1);
cv(Vaxis==2) = bb(2,Vaxis==2);

bnu = bu./(bu.*cv-bv.*cu);
bnv = -bv./(bu.*cv-bv.*cu);
cnu = cv./(bu.*cv-bv.*cu);
cnv = -cu./(bu.*cv-bv.*cu);

vu = cc(3,:);
vu(Uaxis==1) = cc(1,Uaxis==1);
vu(Uaxis==2) = cc(2,Uaxis==2);
vv = cc(3,:);
vv(Vaxis==1) = cc(1,Vaxis==1);
vv(Vaxis==2) = cc(2,Vaxis==2);

nu = normals(3,:);
nu(Uaxis==1) = normals(1,Uaxis==1);
nu(Uaxis==2) = normals(2,Uaxis==2);
nv = normals(3,:);
nv(Vaxis==1) = normals(1,Vaxis==1);
nv(Vaxis==2) = normals(2,Vaxis==2);
nw = normals(3,:);
nw(dom==1) = normals(1,dom==1);
nw(dom==2) = normals(2,dom==2);
nu = nu./nw;
nv = nv./nw;
lambda_num = lambda_num./nw;

X = zeros(3,size(x,2));
isValid = logical(zeros(1,size(x,2)));
for i = 1:size(x,2)
  Du = D(Uaxis,i)';
  Dv = D(Vaxis,i)';
  Dw = D(dom,i)';

  % Get distance to triangles:
  lambda = lambda_num./(Dw+nu.*Du+nv.*Dv);

  % Get 3D intersection of ray and plane passing through each face:
  Pu = Cu + lambda.*Du - vu;
  Pv = Cv + lambda.*Dv - vv;
  
  % Get barycentric coordinates:
  w1 = bnu.*Pv+bnv.*Pu;
  w2 = cnu.*Pu+cnv.*Pv;
  w3 = w1+w2;
  
  % Find which triangle point lives inside:
  n = find((w1>=0)&(w2>=0)&(w3<=1)&(lambda<=0));
  
  if ~isempty(n)
    [maxLambda,nn] = max(lambda(n));
    X(:,i) = D(:,i)*maxLambda+C;
    isValid(i) = 1;
  end
end

% $$$ foo = max(max(0,w1-1),max(-w1,0)) + max(max(0,w2-1),max(-w2,0)) + max(max(0,w3-1),max(-w3,0));


return;


addpath ./ToolboxCopy;

plyFile = '/Users/brussell/work/Archaeology/Data/3Dmodel/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_shortRemoved.ply';

[vertices,faces] = mexReadPly(plyFile);

% Get camera:
load /Users/brussell/work/Archaeology/Data/SynthesizeViewpoints/CameraStructVisible_v3.mat;

i = 2770

P = CameraStruct(i).K*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];

% Lambertian output:
imgLam = imread('GenerateLambertian/OUT/0000.ppm');

% Click on point:
clf;
imshow(imgLam);
hold on;
x = [];
y = [];
for i = 1:10
  [x(i),y(i),button] = ginput(1);
  plot(x(i),y(i),'r+');
end

x = [x; y];

tic;
[X,isValid] = getCorrespondences3d2d_v2(vertices,faces,P,x);
toc

figure;
plot3(X(1,isValid),X(2,isValid),X(3,isValid),'r');
hold on;
plot3(X(1,isValid),X(2,isValid),X(3,isValid),'bo');
axis equal;

figure;
imshow(imgLam);
hold on;
plot(x(1,isValid),x(2,isValid),'r');
plot(x(1,isValid),x(2,isValid),'bo');
