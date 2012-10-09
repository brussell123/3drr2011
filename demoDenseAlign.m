% This code runs the dense painting to 3D model alignment procedure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change these paths:
SRC_PATH = './code';

HOME_PAINTINGS = './Paintings';

% 3D model information:
meshFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
normalsFileName = './normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean.ply';
holesFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_holes.txt';
meshColoredFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';

% Output directory:
OUTDIR = './cache/DenseAlignResults';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(fullfile(SRC_PATH,'LIBS/globalPb/lib'));
addpath(fullfile(SRC_PATH,'LIBS/BerkeleyPB'));
addpath(SRC_PATH);

BIN_RENDER = fullfile(SRC_PATH,'LIBS/GenerateLambertian/generate_colored');
BIN_LINE = fullfile(SRC_PATH,'LIBS/GenerateLambertian/rtsc');
BIN_SEGMENT = fullfile(SRC_PATH,'LIBS/globalPb/lib/segment');

% Painting 02:
PAINTING_FNAME = fullfile(HOME_PAINTINGS,'painting02_down.jpg');

% Camera matrix from scene retrieval:
P = [105.833313 286.452148 -745.784668 -514.688416; 420.080933 675.605957 223.371887 -215.732361; 0.972418 -0.089354 -0.215453 -0.719108];

% Read painting:
imgPainting = imread(PAINTING_FNAME);
if size(imgPainting,3) ~= 3
  imgPainting = repmat(imgPainting,[1 1 3]);
end
imageSize = size(imgPainting);

% Run dense alignment:
[Pest,cost,out] = DenseAlign(imgPainting,P,meshFileName,normalsFileName,holesFileName,BIN_SEGMENT,BIN_LINE,OUTDIR);

% Display alignment:
imgCol = meshGenerateColored(Pest,meshColoredFileName,imageSize,BIN_RENDER);
figure; imshow(imgCol);

% $$$ imgLines = meshLineDrawing(Pest,meshFileName,normalsFileName,holesFileName,imageSize);
% $$$ imgOverlay2 = overlayLines(imgPainting,imgLines);
% $$$ 
% $$$ figure; imshow(imgPainting); title('Painting');
% $$$ figure; imshow(imgOverlay2); title('Final alignment');

return;
