addpath ./code;

meshColoredFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

% mexReadPly:
[vertices,faces,colors] = mexReadPly(meshColoredFileName);

% fastNN:
x = single(rand(2,10));
[aa,bb,vv,nn] = fastNN(x,x);
