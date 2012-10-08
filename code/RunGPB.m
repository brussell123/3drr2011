function [gPb,theta,gPb_full] = RunGPB(img,BIN_SEGMENT,CACHE_DIR)

if ~exist(fullfile(CACHE_DIR,'gpb.mat'),'file')
  img = double(img)/255;
  
  srgb2lab = makecform('srgb2lab');
  lab2srgb = makecform('lab2srgb');
  
  imgLAB = applycform(img,srgb2lab); % convert to L*a*b*
  max_luminosity = 100;
  L = imgLAB(:,:,1)/max_luminosity;
  imgEq = imgLAB;
  imgEq(:,:,1) = adapthisteq(L,'NumTiles',[16 16],'ClipLimit',0.1)*max_luminosity;
% $$$ imgEq(:,:,1) = adapthisteq(L)*max_luminosity;
  imgEq = applycform(imgEq,lab2srgb);
  
  tmpName = [tempname '.jpg'];
  imwrite(imgEq,tmpName);
  
  tic;
    rsz = 0.5;
    [gPb,gPb_full,theta] = globalPb(tmpName,'',rsz,BIN_SEGMENT);
  toc;
  
  if ~exist(CACHE_DIR,'dir')
    mkdir(CACHE_DIR);
  end
  save(fullfile(CACHE_DIR,'gpb.mat'),'gPb','gPb_full','theta');
  
  delete(tmpName);
else
  load(fullfile(CACHE_DIR,'gpb.mat'));
end
