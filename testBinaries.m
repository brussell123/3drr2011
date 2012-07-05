addpath ./code;

meshColoredFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

[vertices,faces,colors] = mexReadPly(meshColoredFileName);
