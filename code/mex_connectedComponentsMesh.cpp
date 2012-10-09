#include "mex.h"

int Find(int p,int *parents) {
  if(parents[p]==p) return p;
  parents[p] = Find(parents[p],parents);
  return parents[p];
}

void Union(int p,int q,int *parents,int *ranks) {
  int pRoot = Find(p,parents);
  int qRoot = Find(q,parents);
  if(ranks[pRoot] > ranks[qRoot]) parents[qRoot] = pRoot;
  else if(pRoot != qRoot) {
    parents[pRoot] = qRoot;
    if(ranks[pRoot] == ranks[qRoot]) ranks[qRoot]++;
  }
}

// Inputs:
// vertices
// faces
//
// Outputs:
// C - Indices for connected components
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs < 2) {
    mexErrMsgTxt("Error: 2 args. needed.");
    return;
  }

  float *vertices = (float*)mxGetData(prhs[0]);
  int *faces = (int*)mxGetData(prhs[1]);

  int dimVert = mxGetM(prhs[0]);
  int dimTri = mxGetM(prhs[1]); // Assume for now faces are triangles
  int Nvertices = mxGetN(prhs[0]);
  int Nfaces = mxGetN(prhs[1]);

  plhs[0] = mxCreateNumericMatrix(1,Nvertices,mxINT32_CLASS,mxREAL);
  int *parents = (int*)mxGetData(plhs[0]);

  // Allocate memory:
  int *ranks = (int*)mxMalloc(Nvertices*sizeof(int));

  // Initialize memory:
  for(int i = 0; i < Nvertices; i++) parents[i] = i;
  for(int i = 0; i < Nvertices; i++) ranks[i] = 0;
  
  // Merge connected components:
  for(int i = 0; i < Nfaces; i++) {
    Union(faces[0+i*3]-1,faces[1+i*3]-1,parents,ranks);
    Union(faces[1+i*3]-1,faces[2+i*3]-1,parents,ranks);
    Union(faces[2+i*3]-1,faces[0+i*3]-1,parents,ranks);
  }

  // Get final indices for connected components:
  for(int i = 0; i < Nvertices; i++) Find(i,parents);

  // Make connected components one-based:
  for(int i = 0; i < Nvertices; i++) parents[i]++;

  // Free memory:
  mxFree(ranks);
}
