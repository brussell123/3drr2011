all win32 linux32 linux64 clean:
	$(MAKE) -C libsrc $@
	$(MAKE) -C gluit $@
	$(MAKE) -C utilsrc $@

debug:
	$(MAKE) -C libsrc DEBUG=y
	$(MAKE) -C gluit DEBUG=y
	$(MAKE) -C utilsrc DEBUG=y

FINDCMD = find trimesh2 -name 'OBJ*' -prune -o -name CVS -prune -o -type f -print

tar:
	cd .. && tar zcvf trimesh2.tar.gz `$(FINDCMD) | sort`

zip:
	cd .. && $(FINDCMD) | sort | zip -9 trimesh2 -@

.PHONY : all clean debug default tar win32 zip

