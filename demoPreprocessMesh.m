SRC_PATH = './code';

addpath(SRC_PATH);

BIN_SMOOTH_NORMALS = fullfile(SRC_PATH,'LIBS/GenerateLambertian/smooth_normals');

% Input files:
PLY_PMVS = './pompeii_pmvs_sample_0.1.ply';
PLY_Poisson = './pompeii_large66_sample_0.1_poisson_depth_14.ply';

% Outputs:
outClean = './pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
outHolesTxt = './pompeii_large66_sample_0.1_poisson_depth_14_clean_holes.txt';
normalsFileName = './normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';

% Parameters:
triDistToPMVS = 0.5;
sigmaNormals = 12;

% Clean mesh:
[vertices,faces,holes] = cleanPly(PLY_PMVS,PLY_Poisson,[],triDistToPMVS);

% Remove close-by vertices (for numerical stability):
[vertices,faces,holes] = removeCloseByVertices(vertices,faces,holes);

% Write mesh:
mexWritePly(outClean,vertices,faces);

% Write holes as ASCII text:
fp = fopen(outHolesTxt,'w');
fprintf(fp,'%d ',length(holes));
fprintf(fp,'%d ',holes);
fclose(fp);

% Generate smoothed normals for mesh (for line drawing code):
GenerateSmoothNormals(outClean,normalsFileName,BIN_SMOOTH_NORMALS,sigmaNormals);

return;
