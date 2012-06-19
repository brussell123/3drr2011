function [BH,mean_dist]=sc_compute_v2(Bsamp,Tsamp,mean_dist,out_vec,nbins_theta,nbins_r,r_inner,r_outer,nbins_edge_ori,Z);
% [BH,mean_dist]=sc_compute_v2(Bsamp,Tsamp,mean_dist,out_vec);
%
% compute (r,theta) histograms for points along boundary 
%
% Bsamp is 2 x nsamp (x and y coords.)
% Tsamp is 1 x nsamp (tangent theta)
% out_vec is 1 x nsamp (0 for inlier, 1 for outlier)
%
% mean_dist is the mean distance, used for length normalization
% if it is not supplied, then it is computed from the data
%
% outliers are not counted in the histograms, but they do get
% assigned a histogram
%

nsamp=size(Bsamp,2);

% Parameters:
if (nargin < 9) || isempty(nbins_edge_ori)
  nbins_edge_ori = 8;
end
if (nargin < 8) || isempty(r_outer)
  r_outer = 2;
end
if (nargin < 7) || isempty(r_inner)
  r_inner=1/8;
end
if (nargin < 6) || isempty(nbins_r)
  nbins_r = 5;
end
if (nargin < 5) || isempty(nbins_theta)
  nbins_theta=12;
end
if (nargin < 4) || isempty(out_vec)
  out_vec = zeros(1,nsamp);
end

in_vec=out_vec==0;

% compute r,theta arrays
r_array=real(sqrt(dist2(Bsamp',Bsamp'))); % real is needed to
                                          % prevent bug in Unix version
theta_array_abs=atan2(Bsamp(2,:)'*ones(1,nsamp)-ones(nsamp,1)*Bsamp(2,:),Bsamp(1,:)'*ones(1,nsamp)-ones(nsamp,1)*Bsamp(1,:))';
theta_array=theta_array_abs;
% $$$ theta_array=theta_array_abs-Tsamp'*ones(1,nsamp);

% create joint (r,theta) histogram by binning r_array and
% theta_array

% normalize distance by mean, ignoring outliers
if isempty(mean_dist)
   tmp=r_array(in_vec,:);
   tmp=tmp(:,in_vec);
   mean_dist=mean(tmp(:));
end
r_array_n=r_array/mean_dist;

if nargin>=10
  r_array(~Z) = inf;
end

% use a log. scale for binning the distances
r_bin_edges=logspace(log10(r_inner),log10(r_outer),nbins_r);
r_array_q=zeros(nsamp,nsamp);
for m=1:nbins_r
   r_array_q=r_array_q+(r_array_n<r_bin_edges(m));
end
fz=r_array_q>0; % flag all points inside outer boundary

% put all angles in [0,2pi) range
theta_array_2 = rem(rem(theta_array,2*pi)+2*pi,2*pi);
% quantize to a fixed set of angles (bin edges lie on 0,(2*pi)/k,...2*pi
theta_array_q = 1+floor(theta_array_2/(2*pi/nbins_theta));

% Quantize edge orientations:
ori_array_q = 1+floor(nbins_edge_ori*Tsamp/pi);

nbins=nbins_theta*nbins_r*nbins_edge_ori;
BH=zeros(nsamp,nbins);
for n=1:nsamp
  k = 0;
  for i = 1:nbins_edge_ori
    fzn=fz(n,:)&in_vec&(ori_array_q'==i);
    Sn=sparse(theta_array_q(n,fzn),r_array_q(n,fzn),1,nbins_theta,nbins_r);
    BH(n,k+1:k+nbins_theta*nbins_r)=Sn(:)';
    k = k+nbins_theta*nbins_r;
  end
end
