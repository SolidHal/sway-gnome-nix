{
  description = "sway-gnome modules";
  inputs = {
  };

  outputs = {
    self,
    nixpkgs,
  }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules = {
        default = import ./default.nix;
      };
      packages."x86_64-linux".regolith-displayd = pkgs.callPackage ./pkgs/regolith-displayd/default.nix{};
    };
}
