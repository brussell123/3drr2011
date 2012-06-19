function P = getGistViewpoint(CameraStruct,j,imageSize)
% Inputs:
% CameraStruct - Set of sampled viewpoints
% j - Index of sampled viewpoint
% imageSize - Painting size
%
% Outputs:
% P - Camera matrix

% Get painting aspect ratio:
aspectRatio = imageSize(1)/imageSize(2);

% Get best fitting crop to painting of sampled viewpoint:
bb = imageCropAspectRatio([CameraStruct(j).nrows CameraStruct(j).ncols],aspectRatio);

% Compute focal length:
focal = imageSize(2)/(bb(2)-bb(1)+1)*CameraStruct(j).K(1);

% Compute camera matrix:
K = [focal 0 imageSize(2)/2; 0 focal imageSize(1)/2; 0 0 1];
R = CameraStruct(j).R;
C = CameraStruct(j).C;
P = K*R*[eye(3) -C];
