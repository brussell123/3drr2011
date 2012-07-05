addpath ./code;

meshColoredFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

% mexReadPly:
[vertices,faces,colors] = mexReadPly(meshColoredFileName);

% fastNN:
x = single(rand(2,10));
[aa,bb,vv,nn] = fastNN(x,x);

% meshGenerateColored:
BIN_PATH = './code/LIBS/GenerateLambertian/generate_colored';
P = [108.792007 276.910461 -723.832397 -171.125000; 405.367004 654.604614 216.727722 -51.611908; 0.972418 -0.089354 -0.215453 -0.178588];
imgCol = meshGenerateColored(P,meshColoredFileName,imageSize,BIN_PATH);
figure;
imshow(imgCol);

