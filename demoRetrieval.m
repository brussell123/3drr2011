%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change these paths:
SRC_PATH = './code';
SRC_GIST = './code/LIBS/gist';
meshname = './pompeii_large66_poisson_clean.ply';
points_name = './pompeii_pmvs_half_points_only.ply';
meshColoredFileName = './pompeii_large66_sample_0.1_poisson_depth_14_clean_colored.ply';
CACHE_DIR = './cache';
HOME_PAINTINGS = './Paintings';
GT_DIR = './Pompeii_GT';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(SRC_GIST);
addpath(SRC_PATH);

load basis_pompeii.mat;

BIN_VISIBILITY = fullfile(SRC_PATH,'LIBS/GenerateLambertian/visibility_mesh');
BIN_POINT_VIEW = fullfile(SRC_PATH,'LIBS/GenerateLambertian/point_view');

% Sample cameras for virtual viewpoints:
CameraStruct = SampleViewpoints(basis,bbFloor,CACHE_DIR);

% Get visible cameras:
CameraStruct = GetVisibleCameras(CameraStruct,meshname,CACHE_DIR,BIN_VISIBILITY);

% Render sampled viewpoints:
RenderSampledViewpoints(CameraStruct,points_name,CACHE_DIR,BIN_POINT_VIEW);

% Find overlapping views:
OverlappingViews = FindOverlappingViews(CameraStruct,meshColoredFileName,CACHE_DIR);

% Set which painting to work with here:
ndxPainting = 2;

% Set painting filename:
PAINTING_FNAME = fullfile(HOME_PAINTINGS,sprintf('painting%02d.jpg',ndxPainting));

% Get painting to match:
imgPainting = imread(PAINTING_FNAME);
imageSize = size(imgPainting);

% Retrieve nearest viewpoints:
P = ViewpointRetrieval(imgPainting,CameraStruct,OverlappingViews,[],1);

% Synthesize viewpoint:
knn = 2;
imgCol = meshGenerateColored(squeeze(P(:,:,knn)),meshColoredFileName,imageSize);

% Perform scene retrieval evaluation using ground truth:
GT = load(fullfile(GT_DIR,sprintf('Painting%02d.mat',ndxPainting)));
n = EvaluateViewpointRetrieval(meshColoredFileName,P,imageSize,GT.Pgt,GT.imageSize,BIN_RENDER);
