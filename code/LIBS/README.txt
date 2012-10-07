+++ Inside gpb_src/
./Rules.make
./include/math/math.hh
./src/io/formats/image/png.cc
./src/math/exact.cc
./src/math/random/sources/rand_source.cc

make
make matlab

+++ Inside BSE-1.2/
./Makefile.gcc
./util/configure.cc
./util/kmeans.cc
./util/image.cc
./util/segmentation.cc
./group/texture.cc
./apps/unitex.cc

make -f Makefile.gcc segment

+++ Inside globalPb
./lib/globalPb.m
./lib/spectralPb.m
./example.m
