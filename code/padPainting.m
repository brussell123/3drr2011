function [imgOut,Vout,xpaint,P,padVal] = padPainting(imgPainting,V2,xpaint,P)
% Inputs:
% imgPainting
% V2
% xpaint

nrows = size(imgPainting,1);
ncols = size(imgPainting,2);

% Parameters:
padVal = round(0.1*sqrt(nrows^2+ncols^2));

imgOut = zeros(nrows+2*padVal,ncols+2*padVal,3,'uint8');
Vout = zeros(nrows+2*padVal,ncols+2*padVal);
imgOut(padVal+1:padVal+nrows,padVal+1:padVal+ncols,:) = imgPainting;
Vout(padVal+1:padVal+nrows,padVal+1:padVal+ncols) = V2;

xpaint = xpaint+padVal;
P = [1 0 padVal; 0 1 padVal; 0 0 1]*P;
