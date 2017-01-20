{ callPackage, protobuf, ... }:

callPackage ./java-v3.nix {
  version = "3.0.0";
  sha256 = "05qkcl96lkdama848m7q3nzzzdckjc158iiyvgmln0zi232xx7g7";
  protobuf = protobuf;
}
