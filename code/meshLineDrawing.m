function [imgLines,imgLines_rv,imgLines_occ] = meshLineDrawing(P,meshFileName,normalsFileName,holesFileName,imageSize,lineType,BIN_PATH)
% Inputs:
% P - Camera matrices.
% meshFileName - Path to mesh PLY file.
% normalsFileName - Path to PLY file with smoothed normals.
% imageSize - Desired image size.
% lineType - {'rv','occlusion','all'}
%
% Outputs:
% imgLines - Line drawing images.

if nargin < 7
  BIN_PATH = '~/work/Archaeology/MeshCode/LineDrawing/rtsc';
% $$$   BIN_PATH = '~/work/Archaeology/LineDrawing/rtsc-1.5/rtsc';
end
if nargin < 6
  lineType = 'all';
end
if nargin < 5
  error('This function has been updated.  Please include pointer to holes.');
end

% Get line option:
lineOption = '';
switch lineType
 case 'all'
% $$$   lineOption = '';
  lineOption = '-b';
 case 'rv'
  lineOption = '-d';
 case 'occlusion'
% $$$   lineOption = '-r -v';
  lineOption = '-r -v -b';
 otherwise
  error('Invalid lineType');
end

Ncameras = size(P,3);

OUTDIR = tempname;
OUTDIR_CAMERAS = [OUTDIR '_cameras'];
OUTDIR_IMAGES = [OUTDIR '_images'];
cameras_filename = [OUTDIR '_cameras.txt'];
images_filename = [OUTDIR '_images.txt'];
mkdir(OUTDIR_CAMERAS);
mkdir(OUTDIR_IMAGES);

% Get OpenGL camera files and output image names:
fp_cameras = fopen(cameras_filename,'w');
fp_images = fopen(images_filename,'w');
outCameras = cell(1,Ncameras);
outFilenames = cell(1,Ncameras);
for i = 1:Ncameras
  opengl_filename = fullfile(OUTDIR_CAMERAS,sprintf('%08d.txt',i));
  PtoOpenGL(opengl_filename,imageSize,squeeze(P(:,:,i)));
  fprintf(fp_cameras,'%s\n',opengl_filename);
  outCameras{i} = opengl_filename;
  outFilenames{i} = fullfile(OUTDIR_IMAGES,sprintf('%08d.ppm',i));
  fprintf(fp_images,'%s\n',outFilenames{i});
end
fclose(fp_cameras);
fclose(fp_images);

% Run line drawing algorithm:
system(sprintf('%s %s %s %s %s %s %s',BIN_PATH,meshFileName,normalsFileName,holesFileName,cameras_filename,images_filename,lineOption));

% Read output images:
imgLines = zeros(imageSize(1),imageSize(2),3,Ncameras,'uint8');
imgLines_rv = zeros(imageSize(1),imageSize(2),3,Ncameras,'uint8');
imgLines_occ = zeros(imageSize(1),imageSize(2),3,Ncameras,'uint8');
for i = 1:Ncameras
  imgLines(:,:,:,i) = imread(outFilenames{i});
  imgLines_rv(:,:,:,i) = imread(sprintf('%s_rv.ppm',outFilenames{i}));
  imgLines_occ(:,:,:,i) = imread(sprintf('%s_occ.ppm',outFilenames{i}));
  delete(outFilenames{i});
  delete(sprintf('%s_rv.ppm',outFilenames{i}));
  delete(sprintf('%s_occ.ppm',outFilenames{i}));
  delete(outCameras{i});
end

% Delete temporary files:
delete(cameras_filename);
delete(images_filename);
rmdir(OUTDIR_CAMERAS);
rmdir(OUTDIR_IMAGES);

return;

function [imgLines,imgDepth] = meshLineDrawing_v1(P,meshFileName,normalsFileName,imageSize,varargin)
% Inputs:
% P - Camera matrix
% meshFileName - Path to mesh PLY file.
% normalsFileName - Path to PLY file with smoothed normals.
% imageSize
%
% Outputs:

% $$$ BIN_PATH = '~/work/Archaeology/LineMatching/Remake/rtsc-1.5/rtsc';
BIN_PATH = '~/work/Archaeology/LineDrawing/rtsc-1.5/rtsc';

valleys = 0;
ridges = 0;
suggestive = 0;
contours = 0;
apparent = 0;
ar_thresh = 0.1;

for i = 1:length(varargin)
  switch varargin{i}
   case 'valleys'
    valleys = 1;
   case 'ridges'
    ridges = 1;
   case 'suggestive'
    suggestive = 1;
   case 'contours'
    contours = 1;
   case 'apparent'
    apparent = 1;
   case 'rv_thresh'
    ar_thresh = varargin{i+1};
% $$$    case 'ar_thresh'
% $$$     ar_thresh = varargin{i+1};
    i = i+1;
  end
end

flags = '';
if ~suggestive
  flags = sprintf('%s -D',flags);
end
if ~contours
  flags = sprintf('%s -d',flags);
end
if apparent
  flags = sprintf('%s -A',flags);
end
if ridges
  flags = sprintf('%s -r',flags);
end
if valleys
  flags = sprintf('%s -v',flags);
end

% Decompose camera matrix:
[r,q,C] = decomposeP(P);

% $$$ % Get RQ decomposition:
% $$$ [r,q] = rq(P(:,1:3));
% $$$ C = -P(:,1:3)\P(:,4);

% Get focal length:
fov = sqrt(imageSize(1)^2+imageSize(2)^2)/2/r(1);
focal = r(1);

% Get principal point:
px = r(7);
py = r(8);

doRotation = 0;
if doRotation
  % Get rotation matrix:
  angy = asin(q(1,3));
  angx = atan2(-q(2,3)/cos(angy),q(3,3)/cos(angy));
  angz = atan2(-q(1,2)/cos(angy),q(1,1)/cos(angy));
  
  % Adjust X-rotation by PI:
% $$$ angx = angx+pi/4;
% $$$ angx = angx+pi;
% $$$ angy = angy+pi;
  angz = angz+pi;
  qx = [1 0 0; 0 cos(angx) -sin(angx); 0 sin(angx) cos(angx)];
  qy = [cos(angy) 0 sin(angy); 0 1 0; -sin(angy) 0 cos(angy)];
  qz = [cos(angz) -sin(angz) 0; sin(angz) cos(angz) 0; 0 0 1];
  
  qq = [-1 0 0; 0 -1 0; 0 0 1]*qx*qy*qz;
% $$$ qq = qx*qy*qz;
else
  qq = q;
end

% Adjusted camera:
Pnew = [qq -qq*C];

tname = tempname;
outLines = [tname '.ppm'];
outDepth = [tname '.pgm'];

display(sprintf('%s %s %s +%d,%d,%f,%f,%f,%s%f,%s,%s',BIN_PATH,meshFileName,normalsFileName,imageSize(2),imageSize(1),focal,px,py,sprintf('%f,',Pnew'),ar_thresh,outLines,outDepth,flags));
% $$$ system(sprintf('%s +%d,%d,%f,%f,%f,%s%f,%s,%s %s %s',BIN_PATH,imageSize(2),imageSize(1),focal,px,py,sprintf('%f,',Pnew'),ar_thresh,outLines,outDepth,flags,meshFileName,normalsFileName));
% $$$ system(sprintf('%s +%d,%d,0.7770,%s%s,%s %s %s',BIN_PATH,imageSize(2),imageSize(1),sprintf('%f,',Pnew'),outLines,outDepth,flags,meshFileName));
% $$$ display(sprintf('./rtsc +%d,%d,0.7770,%s%s,%s -d -D -r -v %s',imageSize(2),imageSize(1),sprintf('%f,',Pnew'),outLines,outDepth,meshFileName));

imgLines = imread(outLines);
imgDepth = imread(outDepth);

delete(outLines);
delete(outDepth);

return;

meshFileName = '~/work/Archaeology/LineMatching/Remake/rtsc-1.5/allrooms_poisson_0.9.ply';
imageSize = [427 640];

OUTDIR = '~/work/Archaeology/LineMatching/Remake/rtsc-1.5/OutputLines';
Ndx = [125 119 124 118 126 129 383];
for i = 1:length(Ndx)
  P = DB(Ndx(i)).annotation.P;
  imgLines = meshLineDrawing(P,meshFileName,imageSize,'apparent');
  imwrite(imgLines,fullfile(OUTDIR,sprintf('%06d_apparent.ppm',Ndx(i))));
  imgLines = meshLineDrawing(P,meshFileName,imageSize,'suggestive','contours');
  imwrite(imgLines,fullfile(OUTDIR,sprintf('%06d_suggestive+contours.ppm',Ndx(i))));
  imgLines = meshLineDrawing(P,meshFileName,imageSize,'contours');
  imwrite(imgLines,fullfile(OUTDIR,sprintf('%06d_contours.ppm',Ndx(i))));
  imgLines = meshLineDrawing(P,meshFileName,imageSize,'ridges','valleys');
  imwrite(imgLines,fullfile(OUTDIR,sprintf('%06d_ridges+valleys.ppm',Ndx(i))));
end

for i = 1:length(Ndx)
  img = imread(DB(Ndx(i)).annotation.filename);
  img = imresize(img,imageSize);
% $$$   imwrite(img,fullfile(OUTDIR,sprintf('%06d.jpg',Ndx(i))));
  imgEdge = 1-edge(rgb2gray(img),'canny');
  imwrite(imgEdge,fullfile(OUTDIR,sprintf('%06d_canny.ppm',Ndx(i))));
end
