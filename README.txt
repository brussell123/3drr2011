bcr@cs.washington.edu
josef.sivic@ens.fr 
jean.ponce@ens.fr
helene.dessales@ens.fr


This code aligns historical paintings of Pompeii to a 3D model
constructed from photographs.  Please see the following publication
for more information:

B. C. Russell, J. Sivic, J. Ponce, and H. Dessales.
Automatic Alignment of Paintings and Photographs Depicting a 3D Scene.
3rd International IEEE Workshop on 3D Representation for Recognition (3dRR-11),
associated with ICCV 2011.

Note that this code is particularly fitted to the Pompeii model.

Disclaimers: The authors, INRIA, and Ecole Normale Supérieure have no
liability of any kind or nature in connection with your use of this
software, including liability for any consequential or incidental
damages or damage to your computer hardware or software or self, and
the entire risk of use (including without limitation any damage to
your computer hardware or software) resides with you.

You expressly agree that the use of this software is at your sole
risk. This software is provided on an "as is" and "as available" basis
for your use, without warranties of any kind, either express or
implied, unless such warranties are legally incapable of exclusion. 

Note that this is research code.  The authors will not provide
extensive support.


RUNNING THE CODE:

1. Start Matlab and type "compile" to compile all needed binaries.

2. Run "demoPreprocessMesh" to pre-process the 3D data.

3. Run "demoRetrieval" to perform coarse alignment by view-sensitive
retrieval.

4. Run "demoDenseAlign" to perform fine alignment by matching
view-dependent contours.


NEEDED LIBRARIES:

1. libjpeg on mac:
http://ethan.tira-thompson.com/Mac_OS_X_Ports.html
