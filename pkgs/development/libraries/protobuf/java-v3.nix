{ stdenv
, fetchFromGitHub
#, autoreconfHook, zlib, gmock
, version, sha256, protobuf
, jre
, jdk
, ...
}:

stdenv.mkDerivation rec {
  name = "protobuf-java-${version}";

  # make sure you test also -A pythonPackages.protobuf
  src = fetchFromGitHub {
    owner = "google";
    repo = "protobuf";
    rev = "v${version}";
    inherit sha256;
  };

  #postPatch = ''
  #  rm -rf gmock
  #  cp -r ${gmock.src}/googlemock gmock
  #  cp -r ${gmock.src}/googletest googletest
  #  chmod -R a+w gmock
  #  chmod -R a+w googletest
  #  ln -s ../googletest gmock/gtest
  #'' + stdenv.lib.optionalString stdenv.isDarwin ''
  #  substituteInPlace src/google/protobuf/testing/googletest.cc \
  #    --replace 'tmpnam(b)' '"'$TMPDIR'/foo"'
  #'';

  buildInputs = [ protobuf jdk ];
  buildPhase = ''
    cd java && \
      protoc --java_out=core/src/main/java -I../src \
      ../src/google/protobuf/descriptor.proto
    cd core/src/main/java && mkdir lib && \
    jar cvf lib/protobuf.jar com/google/protobuf/*java
  '';
  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/lib
    cp ./lib/protobuf.jar $out/lib
    '';

  meta = {
    description = "Google's data interchange format";
    longDescription =
      ''Protocol Buffers are a way of encoding structured data in an efficient
        yet extensible format. Google uses Protocol Buffers for almost all of
        its internal RPC protocols and file formats.
      '';
    license = stdenv.lib.licenses.bsd3;
    platforms = stdenv.lib.platforms.unix;
    homepage = https://developers.google.com/protocol-buffers/;
  };

  passthru.version = version;
}
