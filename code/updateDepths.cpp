// updateDepths.cpp
// To compile:
// mex updateDepths.cpp

#include <math.h>
#include "mex.h"

#define INF FLT_MAX
#define EPS 2.2204e-16

int min(int a,int b) {
  if(a<b) return a;
  return b;
}
int max(int a,int b) {
  if(a>b) return a;
  return b;
}

// Inputs:
// x
// y
// depth
// isValid
// w - Search radius
//
// Outputs:
// x
// y
// v
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs != 5) {
    mexErrMsgTxt("Error: 5 args. needed.");
    return;
  }

  // Get inputs:
  int *x = (int*)mxGetData(prhs[0]);
  int *y = (int*)mxGetData(prhs[1]);
  float *depth = (float*)mxGetData(prhs[2]);
  bool *isValid = (bool*)mxGetData(prhs[3]);
  int w = *(int*)mxGetData(prhs[4]);

  int M = mxGetM(prhs[2]);
  int N = mxGetN(prhs[2]);
  int D = mxGetNumberOfElements(prhs[0]);

  // Allocate outputs:
  plhs[0] = mxCreateNumericMatrix(D,1,mxINT32_CLASS,mxREAL);
  int *xout = (int*)mxGetData(plhs[0]);
  plhs[1] = mxCreateNumericMatrix(D,1,mxINT32_CLASS,mxREAL);
  int *yout = (int*)mxGetData(plhs[1]);
  plhs[2] = mxCreateNumericMatrix(D,1,mxLOGICAL_CLASS,mxREAL);
  bool *vout = (bool*)mxGetData(plhs[2]);

//   // Search radius:
//   int w = 5;

  for(int i = 0; i < D; i++) vout[i] = 0;

  float minDepth;
  int xi, yi;
  for(int i = 0; i < D; i++) {
    xi = x[i];
    yi = y[i];
    minDepth = INF;
    for(int sx = max(xi-w-1,0); sx < min(xi+w,N); sx++) {
      for(int sy = max(yi-w-1,0); sy < min(yi+w,M); sy++) {
	if((depth[sy+sx*M] < minDepth) && isValid[sy+sx*M]) {
	  minDepth = depth[sy+sx*M];
	  xout[i] = sx+1;
	  yout[i] = sy+1;
	  vout[i] = 1;
	}
      }
    }
  }
}
