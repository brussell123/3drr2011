function GenerateSmoothNormals(meshFileName,normalsFileName,BIN_FNAME,sigma)

if nargin < 4
  sigma = 12;
end

system(sprintf('%s %s %s %f',BIN_FNAME,meshFileName,normalsFileName,sigma));
