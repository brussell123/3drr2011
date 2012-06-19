function imgOverlay = overlayEdgeMaps(V1,V2)
% Inputs:
% V1 - 3D model edges (strong responses are black on white background)
% V2 - Painting edges
%
% Outputs:
% imgOverlay

[M,N] = size(V1);

imgOverlay = ones(M,N,3);
imgOverlay(:,:,2) = V2;
imgOverlay(:,:,3) = V2;
imgOverlay2 = ones(M,N,3);
imgOverlay2(:,:,1) = V1;
imgOverlay2(:,:,2) = V1;
imgOverlay = 0.5*(imgOverlay+imgOverlay2);

% $$$     imgOverlay = ones(imageSize(1),imageSize(2),3);
% $$$     imgOverlay(:,:,2) = 1-imdilate(V2pb,strel('disk',2));
% $$$     imgOverlay(:,:,3) = 1-imdilate(V2pb,strel('disk',2));
% $$$     imgOverlay2 = ones(imageSize(1),imageSize(2),3);
% $$$     imgOverlay2(:,:,1) = V1;
% $$$     imgOverlay2(:,:,2) = V1;
% $$$     imgOverlay = 0.5*(imgOverlay+imgOverlay2);
