{ stdenv, fetchurl, alsaLib, pkgconfig
, AudioUnit, AudioToolbox, CoreAudio, CoreServices, Carbon }:

stdenv.mkDerivation rec {
  name = "portaudio-19-20140130";
  
  src = fetchurl {
    url = http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz;
    sha256 = "0mwddk4qzybaf85wqfhxqlf0c5im9il8z03rd4n127k8y2jj9q4g";
  };

  buildInputs = [ pkgconfig ]
    ++ stdenv.lib.optional (!stdenv.isDarwin) alsaLib;

  configureFlags = [ "--disable-mac-universal" ];

  propagatedBuildInputs = stdenv.lib.optionals stdenv.isDarwin [ AudioUnit AudioToolbox CoreAudio CoreServices Carbon ];

  patchPhase = stdenv.lib.optionalString stdenv.isDarwin ''
    sed -i '50 i\
      #include <CoreAudio/AudioHardware.h>\
      #include <CoreAudio/AudioHardwareBase.h>\
      #include <CoreAudio/AudioHardwareDeprecated.h>' \
      include/pa_mac_core.h
  '';

  # not sure why, but all the headers seem to be installed by the make install
  installPhase = ''
    make install
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    # fixup .pc file to find alsa library
    sed -i "s|-lasound|-L${alsaLib.out}/lib -lasound|" "$out/lib/pkgconfig/"*.pc
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    cp include/pa_mac_core.h $out/include/pa_mac_core.h
  '';

  meta = with stdenv.lib; {
    description = "Portable cross-platform Audio API";
    homepage    = http://www.portaudio.com/;
    # Not exactly a bsd license, but alike
    license     = licenses.mit;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.unix;
  };

  passthru = {
    api_version = 19;
  };
}
