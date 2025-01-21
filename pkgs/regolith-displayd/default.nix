{pkgs, ...}:
# let
#   nixpkgs = builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz";
#   };
#     pkgs = import nixpkgs { config = {}; };
# in
pkgs.rustPlatform.buildRustPackage rec {
pname = "regolith-displayd";
version = "3.0";

src = pkgs.fetchFromGitHub {
owner = "regolith-linux";
repo = "regolith-displayd";
rev = "r3_0";
hash = "sha256-6E3oLlRNuEYrhkT0ENvyYzVvebK8JcSR1ubsEI34X0g=";
};

cargoHash = "sha256-vodqVq58P5Mt1WG1lg+NR4DDmfiDq+H9kZyuA6Em1k4=";

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
