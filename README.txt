Warning: this code is particularly fitted to the pompeii model.


This directory contains the source code for the painting alignment
project.

./

Demo scripts and installation instructions.

./code/

All source code here.

./cache/

Cache directory.



I managed to run the PaintingAlignement code v01_beta04. Here is some feedback:
- I had recompile all the libraries and had trouble with most of them, especially:
   * libgomp (openmp) : I finally just removed it, and since it is just for parallel computing it runs without it.
   * libjpeg : I didn´t manage to compile the version you sent. It turned out to be easy to just download install and link the last version from the Internet (8c).
   * libANN : ´make clean´ does not remove lib/libANN.a , which caused some trouble. In general, several ´make clean´ did not really work.
- I had to add the option -m32 -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 in several makefiles.
- the Gist code is not the one given by a google search, maybe it would be good to include it or give a link.
- maybe it would be good to include some data with the code and to use relative path in matlab so that the code run directly.

In general, it may be easier to use a ReadMe file pointing the user to the public libraries, so that he can install them directly for his system, and to the places in the Makefiles where he must add the link to them.
