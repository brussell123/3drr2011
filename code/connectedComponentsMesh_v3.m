function [C,counts] = connectedComponentsMesh_v3(vertices,faces)
% Inputs:
% vertices - 3xN (singles)
% faces - 3xM (int32)
%
% Outputs:
% C - Connected component indices, sorted by rank (int32)
% counts - Number of vertices in each component (int32)

C = mex_connectedComponentsMesh(vertices,faces);
[aa,bb,C] = unique(single(C));
clear aa bb;
cc = hist(C,1:max(C));

% Sort connected component indices:
[vv,nn] = sort(cc,'descend');
clear cc;

% Remove from consideration singletons (for speed since this may be large)
nMult = find(vv>1);
clear vv;
[aa,C] = ismember(C,nn(nMult));
clear aa;
C(C==0) = length(nMult)+1:length(nn);
clear nMult nn;

counts = int32(hist(C,1:max(C)));
C = int32(C);
