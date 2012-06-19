function CameraStruct = SampleViewpoints(basis,bbFloor,CACHE_DIR,xsegp1,xsegp2,Xseg1,Xseg2)
% Sample viewpoints.
%
% Inputs:
% basis - Dominant scene directions [left/right forward/backward up]
% bbFloor - Bounds on floor directions [left right back front]
%
% Outputs:
% CameraStruct

% Parameters:
Nspacing = 25;
floorPaddingRatio = 0.1;
Ndirections = 12; % Number of rotation directions
imageSize = [360 640];
focal = 462.6105;
doDisplay = 0;

if nargin > 3
  doDisplay = 1;
end

if ~exist(fullfile(CACHE_DIR,'CameraStruct_all_samples.mat'),'file')
  % Sample camera positions at regular locations across floor plan:
  floorPadding = floorPaddingRatio*(bbFloor(2)-bbFloor(1));
  floorSpacing = (bbFloor(2)-bbFloor(1))/Nspacing;
  floorPaddingX = (bbFloor(2)-bbFloor(1)+2*floorPadding)/floorSpacing;
  floorPaddingX = (ceil(floorPaddingX)-floorPaddingX)/2*floorSpacing;
  floorPaddingY = (bbFloor(4)-bbFloor(3)+2*floorPadding)/floorSpacing;
  floorPaddingY = (ceil(floorPaddingY)-floorPaddingY)/2*floorSpacing;
  NspacingX = (bbFloor(2)-bbFloor(1)+2*floorPadding+2*floorPaddingX)/floorSpacing;
  NspacingY = (bbFloor(4)-bbFloor(3)+2*floorPadding+2*floorPaddingY)/floorSpacing;
  
  % Sample grid along floor:
  xx = repmat(linspace(bbFloor(1)-floorPadding-floorPaddingX,bbFloor(2)+floorPadding+floorPaddingX,NspacingX),NspacingY,1);
  yy = repmat(linspace(bbFloor(3)-floorPadding-floorPaddingY,bbFloor(4)+floorPadding+floorPaddingY,NspacingY)',1,NspacingX);
  
  if doDisplay
    % Plot sampled camera positions:
    figure;
    plot([xsegp1(1,:); xsegp2(1,:)],[xsegp1(2,:); xsegp2(2,:)]);
    hold on;
    plot([bbFloor(1) bbFloor(2) bbFloor(2) bbFloor(1) bbFloor(1)],[bbFloor(3) bbFloor(3) bbFloor(4) bbFloor(4) bbFloor(3)],'k');
    plot(xx,yy,'r.');
    axis equal;
  end
  
  % Project grid points to get 3D camera positions:
  Cs = basis(:,1:2)*[xx(:) yy(:)]';
  
  if doDisplay
    % Plot sampled cameras and scene lines:
    figure;
    colors = hsv(10);
    for i = 1:size(Xseg1,2)
      plot3([Xseg1(1,i) Xseg2(1,i)],[Xseg1(2,i) Xseg2(2,i)],[Xseg1(3,i) Xseg2(3,i)],'LineWidth',4,'Color',colors(mod(i-1,10)+1,:));
      hold on;
    end
    plot3(Cs(1,:),Cs(2,:),Cs(3,:),'go');
    axis equal;
  end
  
  % Get rotation directions:
  rotAng = linspace(0,2*pi,Ndirections+1);
  rotX = cos(rotAng(1:end-1));
  rotY = sin(rotAng(1:end-1));
  Nvec = basis(:,1:2)*[rotX; rotY];
  Nvec = Nvec./repmat(sum(Nvec.^2,1).^0.5,3,1);
  
  % Get principal point (center of image):
  px = imageSize(2)/2;
  py = imageSize(1)/2;
  
  % Record cameras:
  k = 0;
  CameraStruct = [];
  for i = 1:Ndirections
    % Get rotation matrix:
    R = [cross(Nvec(:,i),basis(:,3)) basis(:,3) Nvec(:,i)]';
    R = [1 0 0; 0 1 0; 0 0 -1]*R;
    for j = 1:size(Cs,2)
      k = k+1;
      CameraStruct(k).C = Cs(:,j);
      CameraStruct(k).R = R;
      CameraStruct(k).K = [focal 0 px; 0 focal py; 0 0 1];
      CameraStruct(k).nrows = imageSize(1);
      CameraStruct(k).ncols = imageSize(2);
    end
  end
  
  save(fullfile(CACHE_DIR,'CameraStruct_all_samples.mat'),'CameraStruct');
else
  load(fullfile(CACHE_DIR,'CameraStruct_all_samples.mat'));
end
