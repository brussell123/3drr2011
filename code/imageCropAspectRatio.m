function [bb,imgCrop] = imageCropAspectRatio(img,aspectRatio)
% Inputs:
% img
% aspectRatio
%
% Outputs:
% imgCrop
% bb

if numel(img)<=3
  nrows = img(1);
  ncols = img(2);
else
  nrows = size(img,1);
  ncols = size(img,2);
end

nr = round(ncols*aspectRatio);
nc = round(nrows/aspectRatio);
if nr <= nrows
  nc = ncols;
else
  nr = nrows;
end
bb = [floor(ncols/2)-floor(nc/2)+1 floor(ncols/2)+floor(nc/2) nrows/2-nr/2+1 nrows/2+nr/2];

if numel(img)<=3
  imgCrop = [];
else
  imgCrop = img(bb(3):bb(4),bb(1):bb(2),:);
end
