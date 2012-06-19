function n = nonMaxSuppress(Nrank,ProbInlier)
% Inputs:
% Nrank - Indices of rank ordering of camera matrices
% ProbInlier - Pairwise probability of inlier over all cameras
%
% Outputs:
% n - Indices of non-max suppressed camera matrices

nValid = logical(ones(1,length(Nrank)));
n = [];
for i = 1:length(Nrank)
% $$$   display(sprintf('%d out of %d: %d',i,length(Nrank),sum(nValid)));
  if nValid(Nrank(i))
    n(end+1) = Nrank(i);
    nValid(Nrank(i)) = 0;
    nValid(find(ProbInlier(Nrank(i),:))) = 0;
  end
end

return;



OUT_GIST_MAT = '../SynthesizeViewpoints/NN/Painting02/gist.mat';

tt = load(OUT_GIST_MAT);

% Find NN using gist:
d = sum(abs(tt.gistScene-repmat(tt.gistPainting,1,length(CameraStruct))),1);
[v,n] = sort(d);


nNonMax = nonMaxSuppress(n,ProbInlier);

% Display images:
for i = 1:25
  img = imread(CameraStruct(nNonMax(i)).imgName);
  
  clf;
  imshow(img);
  pause;
end
