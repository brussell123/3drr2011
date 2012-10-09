function [vertices,faces,holes] = removeCloseByVertices(vertices,faces,holes,thresh)
% Removes vertices that are very close to each other.  This is necessary
% for numerical stability (e.g. for normal computation).
%
% Inputs:
% vertices
% faces
% holes - Vertex indices that border holes
% thresh
%
% Outputs:
% vertices
% faces
% holes

% Parameters:
if nargin < 4
  thresh = 5e-5;
  thresh = 1e-3;
  thresh = 1.1e-3;
end

% Remove indices with short edge lengths:
display('Removing indices with short edge lengths...');
ndx = [1 2; 2 3; 1 3];
subNdx = int32(1:size(vertices,2));
marked = logical(zeros(1,size(vertices,2)));
for i = 1:3
  display(sprintf('%d out of 3',i));
  edgeLength = vertices(:,faces(ndx(i,1),:))-vertices(:,faces(ndx(i,2),:));
  edgeLength = sum(edgeLength.*edgeLength,1).^0.5;
  n = find(edgeLength<thresh);
  for j = 1:length(n)
    if mod(j,10000)==0
      display(sprintf('%d: %d out of %d',i,j,length(n)));
    end
    fi = min(faces(ndx(i,:),n(j)));
    fj = max(faces(ndx(i,:),n(j)));
    vertices(:,fi) = mean([vertices(:,fi) vertices(:,fj)],2);
    subNdx(fj) = fi;
    marked(fj) = 1;
% $$$     faces(faces==fj) = fi;
% $$$ % $$$     for k = 1:3
% $$$ % $$$       nn = (faces(k,:)==fj);
% $$$ % $$$       faces(k,nn) = fi;
% $$$ % $$$     end
  end
end

n = find(marked);
for i = 1:length(n)
  pp = n(i);
  stack = [];
  while marked(subNdx(pp))
    stack(end+1) = pp;
    pp = subNdx(pp);
  end
  subNdx(stack) = subNdx(pp);
end

faces = subNdx(faces);
holes = subNdx(holes);

% Remove faces with duplicate indices:
display('Removing faces with duplicate indices...');
nRemove = find((faces(1,:)==faces(2,:))|(faces(2,:)==faces(3,:))|(faces(1,:)==faces(3,:)));
faces(:,nRemove) = [];

% Get set of valid vertex indices:
vNdx = zeros(1,size(vertices,2),'int32');
vNdx(faces) = 1;
vNdx = find(vNdx);
% $$$ vNdx = unique(faces);

% Change vertex indices to account for discarded vertices:
display('Changing vertex indices...');
for j = 1:size(faces,1)
  [aa,nn] = ismember(faces(j,:),vNdx);
  faces(j,:) = nn;
end
[aa,nn] = ismember(holes,vNdx);
holes = nn;

vertices = vertices(:,vNdx);
faces = int32(faces);
holes = int32(holes);

% $$$ mexWritePly('foo3.ply',vertices(:,holes),[]);

display('Done!');

return;

[vertices,faces] = mexReadPly('debug_subWall_v2.ply');
[vertices,faces] = removeCloseByVertices(vertices,faces);
mexWritePly('debug_subWall_v3.ply',vertices,faces);


[vertices,faces] = mexReadPly('../rtsc-1.5/foo.ply');
[vertices,faces] = removeCloseByVertices(vertices,faces);
mexWritePly('debug_subWall_v3.ply',vertices,faces);


addpath ~/work/MatlabLibraries/BundlerToolbox;
addpath ~/work/Archaeology/FlyThrough/OpenGL;
addpath ~/work/Archaeology/TextureMesh;

plyFile = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean_trimmed.ply';
outPlyFile = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean_trimmed_shortRemoved.ply';

[vertices,faces] = mexReadPly(plyFile);
[vertices,faces] = removeCloseByVertices(vertices,faces);
mexWritePly(outPlyFile,vertices,faces);


plyFile = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean.ply';
outPlyFile = '/data/public_html/russell/Archaeology/3Dmodel/tmp10_depth_14_clean_shortRemoved.ply';

[vertices,faces] = mexReadPly(plyFile);
[vertices,faces] = removeCloseByVertices(vertices,faces);
mexWritePly(outPlyFile,vertices,faces);
