function imgOverlay2 = overlayLines(img,imgLines)
% Inputs:
% img
% imgLines
%
% Outputs:
% imgOverlay

% Overlay edges:
ll = double(imgLines)/255;
imgOverlay2 = zeros(size(img));
imgOverlay2(:,:,1) = 255;
imgOverlay2(:,:,2) = 255;
imgOverlay2 = uint8((1-ll).*imgOverlay2 + ll.*double(img));

