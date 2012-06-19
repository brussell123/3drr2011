# DEBUG = y
TRIMESHDIR = ../trimesh2
MAKERULESDIR = $(TRIMESHDIR)
INCLUDES = -I$(TRIMESHDIR)/include -I../jpeg-8a/src/OUT/include
LIBDIR = -L$(TRIMESHDIR)/lib.$(UNAME) -L../jpeg-8a/src/OUT/lib

include $(MAKERULESDIR)/Makerules
ifeq ($(UNAME),Win32)
  COPTS += -mwindows
endif

SOURCES = generate_lambertian.cc generate_colored.cc
OFILES = $(addprefix $(OBJDIR)/,$(SOURCES:.cc=.o))
PROGS = point_view$(EXE) visibility_mesh$(EXE) generate_lambertian$(EXE) generate_colored$(EXE)

default: $(PROGS)

LIBS += -ltrimesh -ljpeg -framework GLUT -framework OpenGL

point_view$(EXE) : $(OBJDIR)/point_view.o
	$(LINK) $(GLLIBS)

visibility_mesh$(EXE) : $(OBJDIR)/visibility_mesh.o
	$(LINK) $(GLLIBS)

generate_colored$(EXE) : $(OBJDIR)/generate_colored.o
	$(LINK) $(GLLIBS)

generate_lambertian$(EXE) : $(OBJDIR)/generate_lambertian.o
	$(LINK) $(GLLIBS)

clean :
	-rm -f $(OFILES) $(OBJDIR)/Makedepend $(OBJDIR)/*.d
	-rm -rf $(OBJDIR)/ii_files
	-rmdir $(OBJDIR)

spotless : clean
	-rm -f $(PROGS)
	-rmdir $(DESTDIR)

VERSION = 1.5

tar:
	cd .. && tar zcvf rtsc-$(VERSION).tar.gz `find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -type f -print | sort`

zip:
	cd .. && find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -print | sort | zip -9 rtsc-$(VERSION).zip -@

