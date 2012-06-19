function RenderSampledViewpoints(CameraStruct,points_name,CACHE_DIR,BIN_POINT_VIEW)
% Inputs:
% CameraStruct
% CACHE_DIR
%
% Outputs:
% CameraStruct

CAM_DIR = fullfile(CACHE_DIR,'Cameras_views');
VIEWS_DIR = fullfile(CACHE_DIR,'Views');

if ~exist(CAM_DIR,'dir')
  mkdir(CAM_DIR);

  for i = 1:length(CameraStruct)
    K = CameraStruct(i).K;
    R = CameraStruct(i).R;
    C = CameraStruct(i).C;
    imageSize = [CameraStruct(i).nrows CameraStruct(i).ncols];
    focal = mean(K([1 5]));
    px = K(7);
    py = K(8);
    P = [R -R*C]';
    
    fp = fopen(fullfile(CAM_DIR,sprintf('%08d.txt',i-1)),'w');
    fprintf(fp,'%f ',P);
    fprintf(fp,'%d %d %f %f %f',imageSize(1),imageSize(2),focal,px,py);
    fclose(fp);
  end
end

if ~exist(VIEWS_DIR,'dir')
  mkdir(VIEWS_DIR);

  % Render views:
  system(sprintf('%s %s %d %s %s 0',BIN_POINT_VIEW,points_name,length(CameraStruct),CAM_DIR,VIEWS_DIR));
end
