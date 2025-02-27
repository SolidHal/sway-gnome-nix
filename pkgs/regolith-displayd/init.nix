{ pkgs, ... }:

# let
#   nixpkgs = builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz";
#   };
#     pkgs = import nixpkgs { config = {}; };
#     extraConfig = "default config content";
# in

pkgs.stdenv.mkDerivation {
  pname = "regolith-displayd";
version = "3.2";

src = pkgs.fetchFromGitHub {
owner = "regolith-linux";
repo = "regolith-displayd";
rev = "r3_2";
hash = "sha256-tjFbTrdRlpLuxlUIo6qOFGoPeMEXLStxOpYcFsmLn2I=";
};

  nativeBuildInputs = [];

  buildInputs = with pkgs; [];

  buildPhase = ''
    patchShebangsAuto $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src/regolith-displayd-init $out/bin/

    substituteInPlace $out/bin/* \
    --replace-quiet /usr/bin/regolith-displayd regolith-displayd    \
  '';


 meta = {
    mainProgram = "regolith-displayd-init";
    description = "Daemon for providing gnome-control-center DisplayConfig DBus bindings for sway. ";
    homepage = "https://github.com/regolith-linux/regolith-displayd";
    license = pkgs.lib.licenses.gpl3Plus;
  };
}
