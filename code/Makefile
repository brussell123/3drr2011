# Set this to point to location of mex:
MEX_BIN=$(MEX_PATH)

# Set this to point to installation of ann_1.1_char library:
INCLUDE_ANN=./LIBS/ann_1.1.2

# Set this to point to trimesh2 library:
INCLUDE_TRIMESH2=./LIBS/trimesh2

# If compiling on mac, then use this (otherwise comment out):
TRIMESH2_EXT=Darwin

# If compiling on 64-bit linux, then use this (otherwise comment out):
#TRIMESH2_EXT=Linux64

all: mexReadPly mexWritePly fastNN mex_hist_cost rayTrace updateDepths

mexReadPly:
	$(MEX_BIN) mexReadPly.cpp -I$(INCLUDE_TRIMESH2)/include -L$(INCLUDE_TRIMESH2)/lib.$(TRIMESH2_EXT) -ltrimesh -lgomp

mexWritePly:
	$(MEX_BIN) mexWritePly.cpp -I$(INCLUDE_TRIMESH2)/include -L$(INCLUDE_TRIMESH2)/lib.$(TRIMESH2_EXT) -ltrimesh -lgomp

fastNN:
	$(MEX_BIN) fastNN.cpp -I$(INCLUDE_ANN)/include -L$(INCLUDE_ANN)/lib -lANN

mex_hist_cost:
	$(MEX_BIN) mex_hist_cost.cpp

rayTrace:
	$(MEX_BIN) rayTrace.cpp

updateDepths:
	$(MEX_BIN) updateDepths.cpp

#clean:
#	rm fastNN.mexa64
