{ lib, stdenv, fetchurl, zlib, bzip2 }:

stdenv.mkDerivation {
  name = "clp-1.16.10";

  src = fetchurl {
    url = "https://www.coin-or.org/download/source/Clp/Clp-1.16.10.tgz";
    sha256 = "1k9s5xnj9ww9x73hk179vqz0lq0rh520m2zv4g97kzfgmzr81n2w";
  };

  configureFlags = "-C";

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ];

  buildInputs = [ zlib bzip2 ];

  # FIXME: move share/coin/Data to a separate output?

  meta = {
    homepage = https://projects.coin-or.org/Clp;
    license = lib.licenses.epl10;
    maintainers = [ lib.maintainers.josephjohncox ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    description = "A linear programming solver";
  };
}
