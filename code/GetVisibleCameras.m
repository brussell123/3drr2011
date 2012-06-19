function CameraStruct = GetVisibleCameras(CameraStruct,meshname,CACHE_DIR,BIN_VISIBILITY)
% Gets indicies of cameras that sufficiently view the 3D scene.
%
% Inputs:
% CameraStruct - Structure with camera parameters for the sampled views.
% meshname - Filename of 3D mesh.
% CACHE_DIR - Location to dump OpenGL camera parameters and visibility masks.
% BIN_VISIBILITY - Binary for computing visibility masks.
%
% Outputs:
% n - Indices into CameraStruct of visible views.

% Parameters:
scaleFactor = 0.25;
minVisibleArea = 0.25;
doDisplay = 0;

% Locations to output camera parameters and visibility masks:
OUT_VIS_DIR = fullfile(CACHE_DIR,'Cameras_visibility');
VISIBILITY_MASKS_DIR = fullfile(CACHE_DIR,'VisibilityMasks');
VIEWS_DIR = fullfile(CACHE_DIR,'Views');

if ~exist(fullfile(CACHE_DIR,'CameraStruct_visible_samples.mat'),'file')
  if ~exist(OUT_VIS_DIR,'dir')
    mkdir(OUT_VIS_DIR);
    
    % Write OpenGL camera parameters to files:
    for i = 1:length(CameraStruct)
      focal = mean(CameraStruct(i).K([1 5]));
      R = CameraStruct(i).R;
      C = CameraStruct(i).C;
      nrows = CameraStruct(i).nrows;
      ncols = CameraStruct(i).ncols;
      P = [R -R*C]';
      
      fp = fopen(fullfile(OUT_VIS_DIR,sprintf('%08d.txt',i-1)),'w');
      fprintf(fp,'%f ',P);
      fprintf(fp,'%d %d %f %f %f',scaleFactor*nrows,scaleFactor*ncols,scaleFactor*focal,scaleFactor*ncols/2,scaleFactor*nrows/2);
      fclose(fp);
    end
  end
  
  if ~exist(VISIBILITY_MASKS_DIR,'dir')
    mkdir(VISIBILITY_MASKS_DIR);
    system(sprintf('%s %s %d %s %s 0',BIN_VISIBILITY,meshname,length(CameraStruct),OUT_VIS_DIR,VISIBILITY_MASKS_DIR));
  end
  
  % Get visibile cameras:
  ndxVisible = logical(zeros(1,length(CameraStruct)));
  for i = 1:length(CameraStruct)
    display(sprintf('%d out of %d',i,length(CameraStruct)));
    
    mask = imread(fullfile(VISIBILITY_MASKS_DIR,sprintf('%08d.jpg',i-1)));
    
    % Get foreground pixels (red):
    mm = (mask(:,:,1)>128)&(mask(:,:,2)<129)&(mask(:,:,3)<129);
    
    if sum(sum(mm))/size(mask,1)/size(mask,2) >= minVisibleArea
      ndxVisible(i) = 1;
    end
  end
  ndxVisible = find(ndxVisible);
  
  if doDisplay
    % Show 2D positions of visible cameras:
    Cvis = zeros(3,length(ndxVisible));
    Nvis = zeros(3,length(ndxVisible));
    for i = 1:length(ndxVisible)
      Cvis(:,i) = CameraStruct(ndxVisible(i)).C;
      Nvis(:,i) = CameraStruct(ndxVisible(i)).R(3,:)';
    end
    xvis = basis*Cvis;
    nvis = basis*Nvis;
    
    sc = -0.1;
    figure;
    plot([xsegp1(1,:); xsegp2(1,:)],[xsegp1(2,:); xsegp2(2,:)],'LineWidth',2);
    hold on;
    plot([bbFloor(1) bbFloor(2) bbFloor(2) bbFloor(1) bbFloor(1)],[bbFloor(3) bbFloor(3) bbFloor(4) bbFloor(4) bbFloor(3)],'k');
    plot(xvis(1,:),xvis(2,:),'r.');
    plot([xvis(1,:); xvis(1,:)+sc*nvis(1,:)],[xvis(2,:); xvis(2,:)+sc*nvis(2,:)],'b');
    axis equal;
  end
  
  % Set final CameraStruct:
  CameraStruct = CameraStruct(ndxVisible);
  for i = 1:length(CameraStruct)
    CameraStruct(i).imgName = fullfile(VIEWS_DIR,sprintf('%08d.jpg',i-1));
  end
  
  save(fullfile(CACHE_DIR,'CameraStruct_visible_samples.mat'),'CameraStruct');
else
  load(fullfile(CACHE_DIR,'CameraStruct_visible_samples.mat'));
end
