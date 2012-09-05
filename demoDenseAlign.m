% This code runs the dense painting to 3D model alignment procedure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change these paths:
SRC_PATH = './code';
SRC_PB = './MathieuDense/BerkeleyPB';

% 3D model information:
meshFileName = './MathieuDense/pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
normalsFileName = './MathieuDense/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
holesFileName = './MathieuDense/pompeii_large66_sample_0.1_poisson_depth_14_clean_holes.txt';
meshColoredFileName = './MathieuDense/pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

% Output directory:
OUTDIR = './cache/DenseAlign';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(SRC_PB);
addpath(SRC_PATH);

BIN_RENDER = fullfile(SRC_PATH,'LIBS/GenerateLambertian/generate_colored');
BIN_LINE = fullfile(SRC_PATH,'LIBS/GenerateLambertian/rtsc');
% $$$ BIN_LINE = '~/work/Archaeology/MeshCode/LineDrawing/rtsc';

% Painting 02:
PAINTING_FNAME = './MathieuDense/painting02_down.jpg';
GPB_FNAME = './MathieuDense/gpb_painting02_down.mat';

% Camera matrix from scene retrieval:
P = [105.833313 286.452148 -745.784668 -514.688416; 420.080933 675.605957 223.371887 -215.732361; 0.972418 -0.089354 -0.215453 -0.719108];

% Read painting:
imgPainting = imread(PAINTING_FNAME);
if size(imgPainting,3) ~= 3
  imgPainting = repmat(imgPainting,[1 1 3]);
end
imageSize = size(imgPainting);

if 0
%%% Run GPB: (Bryan: still working on this for now)
addpath('/Users/brussell/work/Archaeology/ShapeContext/CodeToIntegrate/globalPb/lib');
[gPb,theta,gPb_full] = RunGPB(imgPainting);
% $$$ GPB_FNAME = './MathieuDense/gpb_painting02_down.mat';
% $$$ save(GPB_FNAME,'gPb','theta','gPb_full');
%%%
end

% Get painting features:
[V2,xpaint,tpaint] = paintingFeatures_v3(GPB_FNAME);

if ~exist(OUTDIR,'dir')
  mkdir(OUTDIR);
end

% Run Shape Context alignment:
padVal = 0;
[Pest,cost,out] = alignShapeContext_v7(V2,xpaint,tpaint,meshFileName,normalsFileName,holesFileName,P,padVal,imgPainting,BIN_LINE,OUTDIR);

% Display alignment:
imgCol = meshGenerateColored(Pest,meshColoredFileName,imageSize,BIN_RENDER);
figure; imshow(imgCol);

% $$$ imgLines = meshLineDrawing(Pest,meshFileName,normalsFileName,holesFileName,imageSize);
% $$$ imgOverlay2 = overlayLines(imgPainting,imgLines);
% $$$ 
% $$$ figure; imshow(imgPainting); title('Painting');
% $$$ figure; imshow(imgOverlay2); title('Final alignment');

return;


% $$$ % This code runs the dense painting to 3D model alignment procedure.
% $$$ 
% $$$ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $$$ % Change these paths:
% $$$ SRC_PATH = './code';
% $$$ SRC_PB = '~/work/MatlabLibraries/BerkeleyPB';
% $$$ 
% $$$ % 3D model information:
% $$$ meshFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
% $$$ normalsFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
% $$$ holesFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_holes.txt';
% $$$ 
% $$$ % Output directory:
% $$$ OUTDIR = './cache/DenseAlign';
% $$$ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $$$ 
% $$$ addpath(SRC_PB);
% $$$ addpath(SRC_PATH);
% $$$ 
% $$$ % Painting 02:
% $$$ PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting02_down.jpg';
% $$$ GPB_FNAME = '~/work/Archaeology/ShapeContext/CodeToIntegrate/globalPb/OUT/gpb_painting02_down.mat';
% $$$ 
% $$$ % Camera matrix from scene retrieval:
% $$$ P = [105.833313 286.452148 -745.784668 -514.688416; 420.080933 675.605957 223.371887 -215.732361; 0.972418 -0.089354 -0.215453 -0.719108];
% $$$ 
% $$$ % Read painting:
% $$$ imgPainting = imread(PAINTING_FNAME);
% $$$ if size(imgPainting,3) ~= 3
% $$$   imgPainting = repmat(imgPainting,[1 1 3]);
% $$$ end
% $$$ imageSize = size(imgPainting);
% $$$ 
% $$$ % Get painting features:
% $$$ [V2,xpaint,tpaint] = paintingFeatures_v3(GPB_FNAME);
% $$$ 
% $$$ if ~exist(OUTDIR,'dir')
% $$$   mkdir(OUTDIR);
% $$$ end
% $$$ 
% $$$ % Run Shape Context alignment:
% $$$ padVal = 0;
% $$$ [Pest,cost,out] = alignShapeContext_v7(V2,xpaint,tpaint,meshFileName,normalsFileName,holesFileName,P,padVal,imgPainting,OUTDIR);
% $$$ 
% $$$ % Display alignment:
% $$$ imgLines = meshLineDrawing(Pest,meshFileName,normalsFileName,holesFileName,imageSize);
% $$$ imgOverlay2 = overlayLines(imgPainting,imgLines);
% $$$ 
% $$$ figure; imshow(imgPainting); title('Painting');
% $$$ figure; imshow(imgOverlay2); title('Final alignment');

