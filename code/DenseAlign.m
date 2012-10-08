function [Pest,cost,out] = DenseAlign(imgPainting,P,meshFileName,normalsFileName,holesFileName,BIN_SEGMENT,BIN_LINE,OUTDIR)

if ~exist(OUTDIR,'dir')
  mkdir(OUTDIR);
end

% Get painting features:
[V2,xpaint,tpaint] = paintingFeatures_v3(imgPainting,BIN_SEGMENT,OUTDIR);

% Run Shape Context alignment:
padVal = 0;
[Pest,cost,out] = alignShapeContext_v7(V2,xpaint,tpaint,meshFileName,normalsFileName,holesFileName,P,padVal,imgPainting,BIN_LINE,OUTDIR);
