{ system, inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sway-gnome.displayd;
in {
  options.sway-gnome.displayd = {
    enable = mkEnableOption "Add regolith-displayd binary and services";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (import ./pkgs/regolith-displayd/default.nix { inherit pkgs; })
      (import ./pkgs/regolith-displayd/init.nix { inherit pkgs; })
      # regolith-displayd-init
      kanshi
      killall
    ];

# https://github.com/regolith-linux/regolith-displayd/blob/96af6a84395930c03c0025891cf2c2553e963a00/debian/install
#kanshi-init-service
  systemd.user.services.regolith-init-kanshi = {
    description = "Start Kanshi for Regolith";

    partOf = [ "graphical-session.target" ];
    wants = [ "gnome-session.target" ];
    after = [ "gnome-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/kanshi -c %h/.config/regolith3/kanshi/config";
      Restart = "on-failure";
      StartLimitIntervalSec = 10;
      StartLimitBurst = 5;
    };
  };
#regolith-init-displayd
  systemd.user.services.regolith-init-displayd = {
    description = "Start Regolith Display Daemon";

    partOf = [ "graphical-session.target" ];
    wants = [ "gnome-session.target" ];
    after = [ "gnome-session.target" ];

    requires = [ "regolith-init-kanshi.service" ];
    before = [ "regolith-init-kanshi.service" ];

    startLimitIntervalSec = 30;
    startLimitBurst = 5;

    serviceConfig = {
      Type = "dbus";
      BusName = "org.gnome.Mutter.DisplayConfig";
      ExecStartPre = "/run/current-system/sw/bin/regolith-displayd-init";
      ExecStart = "/run/current-system/sw/bin/regolith-displayd";
      Restart = "on-failure";
      RestartSec = 5;
    };
      wantedBy = [ "sway-gnome.target" ];
  };

  };
}
