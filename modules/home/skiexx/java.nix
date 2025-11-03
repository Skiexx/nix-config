{ pkgs, lib, ... }:

let
  ckeyScript = pkgs.fetchurl {
    url = "https://ckey.run";
    hash = "sha256-1dm78whwib3mi3w3ks663hlhwrjjaghhvcbly1n4bnm5ixffma09=";
    executable = true;
  };
in
{
  home.packages = with pkgs; [
    temurin-bin
    jetbrains.idea-ultimate
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.temurin-bin}/";
  };
}
