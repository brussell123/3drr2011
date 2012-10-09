function [vertices2,facesNew,holes] = cleanPly(plyPMVS,plyPoisson,outPly,triDistToPMVS)
% Remove triangles in mesh that have vertices far away from dense PMVS
% vertices.  Also, keeps only one connected component.
%
% Outputs:
% vertices - Mesh vertices
% faces - Cleaned set of mesh triangles
% holes - Vertex indices that touch holes

% Parameters:
if nargin < 4
  triDistToPMVS = 1;%0.5; % Maximum distance to PMVS point (scaled by median
                          % of max triangle length)
end
percentileTriMaxLength = 99; % Remove triangles that have max edge longer
                             % than this percentile of all max triangle
                             % lengths
threshConnectedComponent = 10000;
threshHoles = 10000;

% Read PMVS vertices:
vertices1 = mexReadPly(plyPMVS);
vertices1 = unique(vertices1','rows')';

% Read Poisson mesh:
[vertices2,faces2] = mexReadPly(plyPoisson);

% Get NN distances:
[D,N] = fastNN(vertices1,vertices2);

% Get median triangle size:
v1 = vertices2(:,faces2(1,:));
v2 = vertices2(:,faces2(2,:));
v3 = vertices2(:,faces2(3,:));
dtri = max([sum((v1-v2).^2,1).^0.5; sum((v1-v3).^2,1).^0.5; sum((v2-v3).^2,1).^0.5],[],1);
threshDistToPMVS = triDistToPMVS*median(dtri);
threshMaxTriLength = prctile(dtri,percentileTriMaxLength);

% $$$ % Take random subset:
% $$$ rp = randperm(size(faces2,2));
% $$$ rp = rp(1:1000);
% $$$ v1 = vertices2(:,faces2(1,rp));
% $$$ v2 = vertices2(:,faces2(2,rp));
% $$$ v3 = vertices2(:,faces2(3,rp));
% $$$ dtri = max([sum((v1-v2).^2,1).^0.5; sum((v1-v3).^2,1).^0.5; sum((v2-v3).^2,1).^0.5],[],1);
% $$$ thresh = median(dtri)/2;

% Get vertices exceeding distance threshold:
n = find(D>=threshDistToPMVS);
% $$$ thresh = 2e-3;
% $$$ n = find(D>=thresh);

% Get faces that connect to vertices exceeding distance threshold:
ndx1 = find(ismember(faces2(1,:),n));
ndx2 = find(ismember(faces2(2,:),n));
ndx3 = find(ismember(faces2(3,:),n));
ndxRem = unique([ndx1 ndx2 ndx3]);

% $$$ % Get faces that have max triangle length exceeding threshold:
% $$$ ndxRem2 = find(dtri>threshMaxTriLength);
% $$$ ndxRem = unique([ndxRem ndxRem2]);

% Remove faces:
facesNew = faces2;
facesNew(:,ndxRem) = [];

% $$$ % DEBUG:
% $$$ mexWritePly(outPly,vertices2,facesNew);

% Remove isolated mesh points:
[C,counts] = connectedComponentsMesh_v3(vertices2,facesNew);
n = find(ismember(C,find(counts<threshConnectedComponent)));
% $$$ % $$$ C = connectedComponentsMesh_v2(vertices2,facesNew);
% $$$ cc = hist(single(C),1:single(max(C)));
% $$$ [v,n] = max(cc);
% $$$ n = find(C~=n);

ndx1 = find(ismember(faces2(1,:),n));
ndx2 = find(ismember(faces2(2,:),n));
ndx3 = find(ismember(faces2(3,:),n));
ndxRem = unique([ndxRem ndx1 ndx2 ndx3]);
facesNew = faces2;
facesNew(:,ndxRem) = [];

% Get faces corresponding to holes:
facesHoles = faces2(:,ndxRem);

% Get connected components of holes:
[C,counts] = connectedComponentsMesh_v3(vertices2,facesHoles);


% Keep small holes:
n = find(ismember(C,find((counts<threshHoles)&(counts>1))));
ndx1 = find(ismember(facesHoles(1,:),n));
ndx2 = find(ismember(facesHoles(2,:),n));
ndx3 = find(ismember(facesHoles(3,:),n));
ndxRemHoles = unique([ndx1 ndx2 ndx3]);
% $$$ facesHoles2 = facesHoles;
facesHoles2 = facesHoles(:,ndxRemHoles);

% $$$ mexWritePly('foo.ply',vertices2,facesHoles2);

% Get hole indices:
ff = unique(facesHoles2(:))';
gg = zeros(1,size(vertices2,2));
gg(facesNew) = 1;
nn = find(gg(ff));
holes = ff(nn);

% $$$ mexWritePly('foo2.ply',vertices2(:,holes),[]);

if (nargin >= 3) && ~isempty(outPly)
  % Write to PLY file:
  mexWritePly(outPly,vertices2,facesNew);
end


return;

addpath ~/work/Archaeology/TextureMesh;

plyPMVS = 'out.ply';
plyPoisson = 'out_poisson.ply';
outPly = 'clean.ply';
cleanPly(plyPMVS,plyPoisson,outPly);

plyPMVS = '~/work/Archaeology/OldVisualizeSIFT/NotreDame/Data2/NotreDame.ply';
plyPoisson = '/home/willow/russell/work/Archaeology/OldVisualizeSIFT/NotreDame/Data2/NotreDame_poisson.ply';
outPly = 'NotreDame_clean.ply';
cleanPly(plyPMVS,plyPoisson,outPly);


plyPMVS = '~/work/Archaeology/OldVisualizeSIFT/NotreDame/Data2/NotreDame_prune.ply';
plyPoisson = '/home/willow/russell/work/Archaeology/OldVisualizeSIFT/NotreDame/Data2/NotreDame_prune_poisson.ply';
outPly = 'NotreDame_prune_clean.ply';
cleanPly(plyPMVS,plyPoisson,outPly);


Nvertices = 111353663;
fp = fopen('tmp.txt');
vertices1 = fscanf(fp,'%f',6*Nvertices);
fclose(fp);
vertices1 = reshape(vertices1,6,Nvertices);
vertices1 = single(vertices1(1:3,:));

vertices1 = unique(vertices1','rows')';


% Latest version:
addpath ~/work/MatlabLibraries/BundlerToolbox;
addpath ~/work/Archaeology/FlyThrough/OpenGL;
addpath ~/work/Archaeology/TextureMesh;

plyPMVS = '/data/public_html/russell/Archaeology/3Dmodel/pompeii_pmvs_10_points_only.ply';
plyPoisson = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14.ply';
outPly = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean.ply';

outPlyTrim = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean_trimmed.ply';
