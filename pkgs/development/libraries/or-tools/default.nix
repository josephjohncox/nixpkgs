{stdenv, fetchgit
, subversion, bison, flex, python
, autoconf, libtool, zlib, gawk
, glpk, which, git, cmake, mono
, google-gflags
, protobuf
, sparsehash
, swig
, cbc
, protobuf_java
, jdk
, clp
, pythonPackages
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
   protobuf_java
   jdk
   clp
   pythonPackages.setuptools
  ];

  #$(GLPK_MAKEFILE)
  #$(SCIP_MAKEFILE)
  #UNIX_SCIP_TAG = $(SCIP_TAG)
  #CLR_KEYFILE = bin/or-tools.snk
  #UNIX_SULUM_VERSION = $(SULUM_TAG)
  #$(SELECTED_JDK_DEF)
  src = fetchgit (stdenv.lib.importJSON ./src.json);
  pythonVersion = python.majorVersion;
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

  enableParallelBuilding = false;
  makeFlags = if enableParallelBuilding then
    "-j$NIX_BUILD_CORES -l $NIX_BUILD_CORES"
    else
    "";
  makeVerbose = true;
  verbose = if makeVerbose then "--debug=v" else "";

  buildPhase = ''
    ${localMakefile}
    make missing_directories
    make all ${verbose} ${makeFlags}
  '';
  installPhase = ''
    mkdir -p tempInstall
    mkdir -p $out
    # mkdir -p $out/site-packages
    make archive
    tar xvf install.tar.gz -C tempInstall/
    cp -r tempInstall/install/* $out/
    # make pypi_archive
    # pythonInstallDir=$out/lib/${pythonPackages.python.libPrefix}/site-packages
    # mkdir -p $pythonInstallDir
    # export PYTHONPATH=''${PYTHONPATH:+''${PYTHONPATH}:}$pythonInstallDir
    # cd temp/ortools && python setup.py install --prefix $out
  '';
  postInstall = "wrapPythonPrograms";
  patchPhase = ''
      #Java
      substituteInPlace makefiles/Makefile.port --replace "sw_vers" "/usr/bin/sw_vers"
      substituteInPlace makefiles/Makefile.port --replace "SELECTED_JDK_DEF = MAC_JDK_HEADERS = \$(wildcard \$(CANDIDATE_JDK_HEADERS))" "MAC_JDK_HEADERS := ${jdk}/include"
      substituteInPlace makefiles/Makefile.port --replace "SELECTED_JDK_DEF = LINUX_JDK_ROOT = \$(firstword \$(wildcard \$(CANDIDATE_JDK_ROOTS)))" "LINUX_JDK_ROOT := ${jdk}"
      substituteInPlace makefiles/Makefile.java.mk --replace "dependencies/install/lib/protobuf.jar" ${protobuf_java}/lib/protobuf.jar
      substituteInPlace makefiles/Makefile.java.mk --replace "dependencies\$Sinstall\$Slib\$Sprotobuf.jar" ${protobuf_java}\$Slib\$Sprotobuf.jar

      # Python
      substituteInPlace makefiles/Makefile.unix --replace "-I/usr/include/python\$(UNIX_PYTHON_VER) -I/usr/lib/python\$(UNIX_PYTHON_VER) \$(ADD_PYTHON_INC)" "-I${python}/include/python\$(UNIX_PYTHON_VER) -I${python}/lib/python\$(UNIX_PYTHON_VER) \$(ADD_PYTHON_INC)"

      # Archiver
      substituteInPlace makefiles/Makefile.archive.mk --replace "cd temp\$S\$(INSTALL_DIR)\$Sinclude && tar -C ..\$S..\$S..\$Sdependencies\$Sinstall\$Sinclude -c -v gflags | tar xvm" ""

      substituteInPlace makefiles/Makefile.archive.mk --replace "cd temp\$S\$(INSTALL_DIR)\$Sinclude && tar -C ..\$S..\$S..\$Sdependencies\$Sinstall\$Sinclude -c -v google | tar xvm" ""

      substituteInPlace makefiles/Makefile.archive.mk --replace "cd temp\$S\$(INSTALL_DIR)\$Sinclude && tar -C ..\$S..\$S..\$Sdependencies\$Sinstall\$Sinclude -c -v sparsehash | tar xvm" ""

      substituteInPlace makefiles/Makefile.port --replace "INSTALL_DIR=or-tools_\$(PORT)_v\$(OR_TOOLS_VERSION)" "INSTALL_DIR=install"
    '';
  dontUseCmakeConfigure = true;
  meta = {
    inherit version;
    description = ''Google's Operations Research tools'';
    license = stdenv.lib.licenses.asl20 ;
    maintainers = [stdenv.lib.maintainers.josephjohncox];
    platforms = stdenv.lib.platforms.all ;
  };
}
