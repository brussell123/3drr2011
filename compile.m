function compile

homedir = pwd;
c = computer; % Get computer type

% Compile trimesh2:
cd('./code/LIBS/trimesh2');
system('make');
cd(homedir);

% Compile libANN:
cd('./code/LIBS/ann_1.1.2');
switch c
 case 'MACI'
  % mac:
  system('make macosx-g++');
 case 'GLNXA64'
  % 64-bit linux:
  system('make linux-g++');
 otherwise
  error('Can only compile mac or 64-bit linux for now.');
end
cd(homedir);

% Compile MEX code:
cd('./code');
switch c
 case 'MACI'
  % mac:
  mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin -ltrimesh -lgomp
  mex mexWritePly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin -ltrimesh -lgomp
 case 'GLNXA64'
  % 64-bit linux:
  mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Linux64 -ltrimesh -lgomp
  mex mexWritePly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Linux64 -ltrimesh -lgomp
 otherwise
  error('Can only compile mac or 64-bit linux for now.');
end

mex fastNN.cpp -I./code/LIBS/ann_1.1.2/include -L./code/LIBS/ann_1.1.2/lib -lANN
mex mex_hist_cost.cpp
mex rayTrace.cpp
mex updateDepths.cpp
cd(homedir);
