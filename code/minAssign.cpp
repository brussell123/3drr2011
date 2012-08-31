// minAssign.cpp
// To compile:
// mex minAssign.cpp

#include "mex.h"

// Inputs:
// distMap
// ndxMap
// N
// inlierThresh
//
// Outputs:
// costs
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs != 4) {
    mexErrMsgTxt("Error: 4 args. needed.");
    return;
  }

  // Get inputs:
  float *dists = (float*)mxGetData(prhs[0]);
  int *ndx = (int*)mxGetData(prhs[1]);
  int N = *(int*)mxGetData(prhs[2]);
  float inlierThresh = *(float*)mxGetData(prhs[3]);

  int D = mxGetNumberOfElements(prhs[1]);

  // Allocate outputs:
  plhs[0] = mxCreateNumericMatrix(1,N,mxSINGLE_CLASS,mxREAL);
  float *costs = (float*)mxGetData(plhs[0]);

  // Initialize output:
  for(int i = 0; i < N; i++) costs[i] = inlierThresh;

  // Main loop:
  int n;
  for(int i = 0; i < D; i++) {
    n = ndx[i]-1;
    if(costs[n] > dists[i]) costs[n] = dists[i];
  }

  return;
}
