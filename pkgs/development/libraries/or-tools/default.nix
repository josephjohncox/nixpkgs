{stdenv, fetchgit
, subversion, bison, flex, python
, autoconf, libtool, zlib, gawk
, glpk, which, git, cmake, mono
, google-gflags
, protobuf
, sparsehash
, swig
, cbc
}:
stdenv.mkDerivation rec{
  version = "5.0";
  name = "or-tools-${version}";
  buildInputs = [
   subversion bison flex python
   autoconf libtool zlib gawk subversion
   glpk which git mono cmake
   google-gflags
   protobuf
   sparsehash
   swig
   cbc
  ];

  #UNIX_CLP_DIR = ${clp}
  #$(GLPK_MAKEFILE)
  #$(SCIP_MAKEFILE)
  #UNIX_SCIP_TAG = $(SCIP_TAG)
  #CLR_KEYFILE = bin/or-tools.snk
  #UNIX_SULUM_VERSION = $(SULUM_TAG)
  #$(SELECTED_JDK_DEF)
  src = fetchgit (stdenv.lib.importJSON ./src.json);
  pythonVersion = python.version;
  localMakefile = ''
    echo \# Local Makefile > Makefile.local
    echo UNIX_PYTHON_VER = ${pythonVersion} >> Makefile.local
    echo UNIX_GFLAGS_DIR = ${google-gflags} >> Makefile.local
    echo UNIX_PROTOBUF_DIR = ${protobuf} >> Makefile.local
    echo UNIX_SPARSEHASH_DIR = ${sparsehash} >> Makefile.local
    echo UNIX_SWIG_BINARY = ${swig}/bin/swig >> Makefile.local
    echo UNIX_CBC_DIR = ${cbc} >> Makefile.local
    echo UNIX_GLPK_DIR = ${glpk} >> Makefile.local
    echo \# Please define UNIX_SLM_DIR to use Sulum Optimization. >> Makefile.local
    echo \# Please define UNIX_GUROBI_DIR and GUROBI_LIB_VERSION to use Gurobi. >> Makefile.local
    echo \# Please define UNIX_CPLEX_DIR to use CPLEX. >> Makefile.local
  '';

  buildPhase = ''
    ${localMakefile}
    make missing_directories
    make all
  '';
  installPhase = '' '';
  patchPhase = ''
      substituteInPlace makefiles/Makefile.port --replace "sw_vers" "/usr/bin/sw_vers"
    '';
  dontUseCmakeConfigure = true;
  meta = {
    inherit version;
    description = ''Google's Operations Research tools'';
    license = stdenv.lib.licenses.bsd3 ;
    maintainers = [stdenv.lib.maintainers.josephjohncox];
    platforms = stdenv.lib.platforms.all ;
  };
}
