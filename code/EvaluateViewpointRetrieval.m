function n = EvaluateViewpointRetrieval(modelname,P,imageSize,Pgt,imageSize_gt,BIN_RENDER)
% Inputs:
% model_name - 3D model name
% P
% imageSize
% Pgt
% imageSize_gt
%
% Outputs:
% n - Index into P of correct retrieval (empty if none are correct)

% Parameters:
threshInlier = 0.2;
threshNinlier = 0.6;

% Get 3D points:
X = mexReadPly(modelname);

if (imageSize(1)~=imageSize_gt(1)) || (imageSize(2)~=imageSize_gt(2))
  % Scale ground truth to be same resolution as input image:
  sc = mean([imageSize(1)/imageSize_gt(1) imageSize(2)/imageSize_gt(2)]);
  Pgt = [sc 0 0; 0 sc 0; 0 0 1]*Pgt;
end

% Perform conversion on camera matrix:
orig.P = P;
orig.Pgt = Pgt;
for i = 1:size(P,3)
  [K,R,C] = decomposeP(squeeze(P(:,:,i)));
  P(:,:,i) = K*[1 0 0; 0 -1 0; 0 0 -1]*R*[eye(3) -C];
end
[K,R,C] = decomposeP(Pgt);
Pgt = K*[1 0 0; 0 -1 0; 0 0 -1]*R*[eye(3) -C];

% Evaluate viewpoint overlap:
pp = evaluateViewpoint(Pgt,P,X,imageSize,threshNinlier,threshInlier);

% Keep only one correct viewpoint based on non-max suppressed indices:
n = min(find(pp>=threshNinlier));

if exist('BIN_RENDER','var')
  % Display top nearest neighbors:
  topNN = 9; % Number of nearest neighbors to show
  pad = 10;
  
  imgCol = meshGenerateColored(orig.P(:,:,1:topNN),modelname,imageSize,BIN_RENDER);

  figure;
  for i = 1:topNN
    subplot(ceil(sqrt(topNN)),ceil(sqrt(topNN)),i);
    img_i = squeeze(imgCol(:,:,:,i));
    if i == n
      img_i(1:pad,:,1) = 0; img_i(1:pad,:,2) = 255; img_i(1:pad,:,3) = 0;
      img_i(:,1:pad,1) = 0; img_i(:,1:pad,2) = 255; img_i(:,1:pad,3) = 0;
      img_i(end-pad+1:end,:,1) = 0; img_i(end-pad+1:end,:,2) = 255; img_i(end-pad+1:end,:,3) = 0;
      img_i(:,end-pad+1:end,1) = 0; img_i(:,end-pad+1:end,2) = 255; img_i(:,end-pad+1:end,3) = 0;
    end
    imshow(img_i);
  end
end
