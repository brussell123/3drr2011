% This code runs the dense painting to 3D model alignment procedure.

% Add Matlab libraries:
addpath ~/work/MatlabLibraries/BerkeleyPB;

% 3D model information:
meshFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
normalsFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
holesFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_holes.txt';
meshColoredFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

% $$$ % "Trimmed" 3D model information:
% $$$ meshFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
% $$$ normalsFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
% $$$ holesFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_holes.txt';
% $$$ meshColoredFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_colored.ply';

% Painting 02:
PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting02.jpg';
fname2 = '~/work/Archaeology/ShapeContext/CodeToIntegrate/globalPb/img/gpb_painting_02_fullres.bmp';
NN_MAT = '~/work/Archaeology/Data/SynthesizeViewpoints/NN/Painting02_NN.mat';
knn = 2;
OUTDIR = [];

% Read painting:
imgPainting = imread(PAINTING_FNAME);
if size(imgPainting,3) ~= 3
  imgPainting = repmat(imgPainting,[1 1 3]);
end
imageSize = size(imgPainting);

% Read gPB for painting:
V2 = imread(fname2);
V2 = mean(double(V2),3)/255;

% Get set of sampled viewpoints:
load /Users/brussell/work/Archaeology/Data/SynthesizeViewpoints/CameraStructVisible_v3.mat;

% Get gist nearest neighbors:
NN = load(NN_MAT);

% Get initial viewpoint from gist:
P = getGistViewpoint(CameraStruct,NN.n(knn),imageSize);

% $$$ OUTDIR = [];

if ~isempty(OUTDIR)
  mkdir(OUTDIR);
end

% $$$ % Get painting features:
% $$$ segFileName = '~/Desktop/FOO/pedro/segment/img/out01_crop.ppm';
% $$$ segFileName = '~/Desktop/FOO/pedro/segment/img/out03.ppm';
% $$$ imgSeg = imread(segFileName);
% $$$ [V2,V2pb,V2theta] = segmentation2lines(imgSeg);

% Get painting features:
[V2,xpaint,tpaint] = paintingFeatures_v2(V2,imgPainting);

% Run Shape Context alignment:
[Pest,cost,out] = alignShapeContext_v6(V2,xpaint,tpaint,meshFileName,normalsFileName,holesFileName,P,imgPainting,OUTDIR);

% Display alignment:
imgLines = meshLineDrawing(Pest,meshFileName,normalsFileName,holesFileName,imageSize);
imgCol = meshGenerateColored(Pest,meshColoredFileName,imageSize);
imgOverlay2 = overlayLines(imgPainting,imgLines);

figure;
imshow(imgOverlay2);
