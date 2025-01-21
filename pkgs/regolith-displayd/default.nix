{pkgs, ...}:
# let
#   nixpkgs = builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz";
#   };
#     pkgs = import nixpkgs { config = {}; };
# in
pkgs.rustPlatform.buildRustPackage rec {
pname = "regolith-displayd";
version = "3.2";

src = pkgs.fetchFromGitHub {
owner = "regolith-linux";
repo = "regolith-displayd";
rev = "r3_2";
hash = "sha256-tjFbTrdRlpLuxlUIo6qOFGoPeMEXLStxOpYcFsmLn2I=";
};

cargoHash = "sha256-9yBKR5Evh42WybIjZ6v4ZVzZL4memgfLARNkqUO/0SY=";

nativeBuildInputs = with pkgs;[pkg-config rustc];
buildInputs = with pkgs;[glib];


#  postInstall = ''
#     mkdir -p $out/bin
#     # cp $src/regolith-displayd-init $out/bin/
#     touch $out/bin/session.txt

#   '';

  meta = {
    mainProgram = "regolith-displayd";
    description = "Daemon for providing gnome-control-center DisplayConfig DBus bindings for sway. ";
    homepage = "https://github.com/regolith-linux/regolith-displayd";
    license = pkgs.lib.licenses.gpl3Plus;
  };
}
