// keymatchmex.cpp

#include <math.h>
#include <vector>
#include "ANN/ANN.h"
#include "mex.h"

// using namespace ann_1_1_char;

/* Create a search tree for the given set of keypoints */
ANNkd_tree *CreateSearchTree(int num_keys,float *keys,int dim,ANNpointArray pts) {
//   /* Create a new array of points */
//   ANNpointArray pts = annAllocPts(num_keys,dim);
  
  for (int i = 0; i < num_keys; i++) {
    memcpy(pts[i], keys + dim * i, sizeof(float) * dim);
  }
  
  /* Create a search tree for k2 */
  ANNkd_tree *tree = new ANNkd_tree(pts, num_keys, dim, 16);
  
  return tree;
}

void MatchKeys(int num_keys1,float *k1,ANNkd_tree *tree2,float *D,int *N,int dim) {
  int max_pts_visit = 200;
  annMaxPtsVisit(max_pts_visit);
  
  /* Now do the search */
  ANNidx nn_idx[2];
  ANNdist dist[2];
  for (int i = 0; i < num_keys1; i++) {
    tree2->annkPriSearch(k1 + dim * i, 2, nn_idx, dist, 0.0);
    D[i] = dist[0];
    N[i] = nn_idx[0]+1;
  }
}

void MatchKeys(int num_keys1,float *k1,ANNkd_tree *tree2,float *D,int *N,float *D2,int *N2,int dim) {
  int max_pts_visit = 200;
  annMaxPtsVisit(max_pts_visit);
  
  /* Now do the search */
  ANNidx nn_idx[2];
  ANNdist dist[2];
  for (int i = 0; i < num_keys1; i++) {
    tree2->annkPriSearch(k1 + dim * i, 2, nn_idx, dist, 0.0);
    D[i] = dist[0];
    N[i] = nn_idx[0]+1;
    D2[i] = dist[1];
    N2[i] = nn_idx[1]+1;
  }
}

// Inputs: keys,keysTarget
// Outputs: matches
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs < 2) {
    mexErrMsgTxt("Error: 2 args. needed.");
    return;
  }

  float *keys = (float*)mxGetData(prhs[0]);
  float *keysTarget = (float*)mxGetData(prhs[1]);

  int dim = mxGetM(prhs[0]);
  int num_keys = mxGetN(prhs[0]);
  int num_keysTarget = mxGetN(prhs[1]);

  /* Create a new array of points */
  ANNpointArray pts = annAllocPts(num_keys,dim);
  ANNkd_tree *tree = CreateSearchTree(num_keys,keys,dim,pts);
    
  // Allocate outputs:
  plhs[0] = mxCreateNumericMatrix(1,num_keysTarget,mxSINGLE_CLASS,mxREAL);
  float *D = (float*)mxGetData(plhs[0]);
  plhs[1] = mxCreateNumericMatrix(1,num_keysTarget,mxINT32_CLASS,mxREAL);
  int *N = (int*)mxGetData(plhs[1]);
  if(nlhs > 2) {
    plhs[2] = mxCreateNumericMatrix(1,num_keysTarget,mxSINGLE_CLASS,mxREAL);
    float *D2 = (float*)mxGetData(plhs[2]);
    plhs[3] = mxCreateNumericMatrix(1,num_keysTarget,mxINT32_CLASS,mxREAL);
    int *N2 = (int*)mxGetData(plhs[3]);

    // Compute likely matches between two sets of keypoints
    MatchKeys(num_keysTarget,keysTarget,tree,D,N,D2,N2,dim);
  }
  else {
    // Compute likely matches between two sets of keypoints
    MatchKeys(num_keysTarget,keysTarget,tree,D,N,dim);
  }


  annDeallocPts(pts);
//   annDeallocPts(tree->thePoints());
//   annDeallocPts(tree->pts);
  delete tree;

  return;
}
