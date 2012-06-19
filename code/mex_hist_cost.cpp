// mex_hist_cost.cpp
// To compile:
// mex mex_hist_cost.cpp

#include <math.h>
#include "mex.h"

#define EPS 2.2204e-16

// Inputs:
// X1
// X2
//
// Outputs:
// C
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs != 2) {
    mexErrMsgTxt("Error: 2 args. needed.");
    return;
  }

  // Get inputs:
  double *X1 = (double*)mxGetData(prhs[0]);
  double *X2 = (double*)mxGetData(prhs[1]);

  int N1 = mxGetM(prhs[0]);
  int N2 = mxGetM(prhs[1]);
  int D = mxGetN(prhs[0]);

  // Allocate outputs:
  plhs[0] = mxCreateNumericMatrix(N1,N2,mxDOUBLE_CLASS,mxREAL);
  double *C = (double*)mxGetData(plhs[0]);

  // Allocate temporary memory:
  double *X1n = (double*)mxMalloc(N1*D*sizeof(double));
  double *X2n = (double*)mxMalloc(N2*D*sizeof(double));

  // Normalize input vectors to sum to one:
  for(int i = 0; i < N1; i++) {
    double tot = EPS;
    for(int j = 0; j < D; j++) tot += X1[i+j*N1];
    for(int j = 0; j < D; j++) X1n[i+j*N1] = X1[i+j*N1]/tot;
  }
  for(int i = 0; i < N2; i++) {
    double tot = EPS;
    for(int j = 0; j < D; j++) tot += X2[i+j*N2];
    for(int j = 0; j < D; j++) X2n[i+j*N2] = X2[i+j*N2]/tot;
  }

  // Compute output:
  double x,y;
  for(int i = 0; i < N1; i++) {
    for(int j = 0; j < N2; j++) {
      C[i+j*N1] = 0;
      for(int k = 0; k < D; k++) {
	x = X1n[i+k*N1];
	y = X2n[j+k*N2];
	C[i+j*N1] += powf(x-y,2)/(x+y+EPS);
      }
      C[i+j*N1] /= 2;
    }
  }

  // Free memory:
  mxFree(X1n);
  mxFree(X2n);
}
