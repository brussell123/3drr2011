function compile

homedir = pwd;

try
  c = computer; % Get computer type
  
  % Compile trimesh2:
  cd('./code/LIBS/trimesh2');
  system('make');
  cd(homedir);
  
  % Compile OpenGL rendering code:
  cd('./code/LIBS/GenerateLambertian');
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
    if exist('./LIBS/trimesh2/lib.Darwin64','dir')
      mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin64 -ltrimesh -lgomp
      mex mexWritePly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin64 -ltrimesh -lgomp
    else
      mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin -ltrimesh -lgomp
      mex mexWritePly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin -ltrimesh -lgomp
    end
   case 'GLNXA64'
    % 64-bit linux:
    mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Linux64 -ltrimesh -lgomp
    mex mexWritePly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Linux64 -ltrimesh -lgomp
   otherwise
    error('Can only compile mac or 64-bit linux for now.');
  end
  
  mex fastNN.cpp -I./LIBS/ann_1.1.2/include -L./LIBS/ann_1.1.2/lib -lANN
  mex mex_hist_cost.cpp
  mex rayTrace.cpp
  mex updateDepths.cpp
  mex minAssign.cpp
  mex mex_connectedComponentsMesh.cpp
  cd(homedir);

  % Compile gPB:
  cd('./code/LIBS/gpb_src');
  system('make');
  system('make matlab');
  system('cp ./matlab/segmentation/*.mexmaci ../globalPb/lib/');
  cd(homedir);
  cd('./code/LIBS/BSE-1.2');
  system('make -f Makefile.gcc segment');
  system('cp ./segment ../globalPb/lib/');
  cd(homedir);
  
catch
  cd(homedir);
end
