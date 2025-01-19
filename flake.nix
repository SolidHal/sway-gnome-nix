{
  description = "sway-gnome modules";
  inputs = {
  };

  outputs = {
    self,
    nixpkgs,
  }:
    {
      nixosModules = {
        default = import ./default.nix;
      };
    };
}
