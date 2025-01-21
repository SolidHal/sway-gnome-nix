{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.sway-gnome;
  notExcluded = pkg: mkDefault (!(lib.elem pkg config.environment.gnome.excludePackages));
  sway-gnome-pkgs = import ./pkgs {inherit config pkgs lib;};
in
  with sway-gnome-pkgs; {
    options = {
      sway-gnome = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    # start regolith components
    imports = [ ./displayd.nix ];

    config = mkIf cfg.enable {
      # enable regolith components
      sway-gnome.displayd.enable = true;

      environment = {


        # write sway config file to manage the gnome session
        etc = {
          "sway/config.d/sway-gnome.conf".source = pkgs.writeText "sway-gnome.conf" ''
            exec ${start-gnome-session}
          '';
        };

        # write sway config file to start and manage waybar
        etc = {
          "sway/config.d/sway-gnome-waybar.conf".source = pkgs.writeText "sway-gnome-waybar.conf" ''
           bar {
            swaybar_command waybar
           }
           '';
        };

        pathsToLink = [
          "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
          "/share/nautilus-python/extensions"
        ];

        # Let nautilus find extensions
        # TODO: Create nautilus-with-extensions package
        sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

        # Override default mimeapps for nautilus
        sessionVariables.XDG_DATA_DIRS = ["${mimeAppsList}/share"];

        systemPackages = with pkgs; [
          adwaita-icon-theme
          gnome-bluetooth
          gnome-color-manager
          gnome-control-center
          qt6Packages.qtwayland
          fuzzel # launcher
          glib # for gsettings
          grim # screjnshot functionality
          gtk3.out # for gtk-launch program
          helvum
          latestWaybar
          orca
          pavucontrol
          phinger-cursors
          libsForQt5.qt5ct
          qt6ct
          slurp # screenshot functionality
          sound-theme-freedesktop
          swayidle
          swaylock
          sway-gnome-desktop
          swww
          wayland
          wlogout
          wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
          xdg-user-dirs
          xdg-utils
        ];
      };

      fonts.packages = with pkgs; [
        cantarell-fonts
        dejavu_fonts
        source-code-pro # Default monospace font in 3.32
        source-sans
        font-awesome
        powerline-fonts
        powerline-symbols
      ];

      networking.networkmanager.enable = mkDefault true;

      programs = {
        bash.vteIntegration = true;
        evince.enable = notExcluded pkgs.gnome.evince;
        file-roller.enable = notExcluded pkgs.gnome.file-roller;
        geary.enable = notExcluded pkgs.gnome.geary;
        gnome-disks.enable = notExcluded pkgs.gnome.gnome-disk-utility;
        seahorse.enable = notExcluded pkgs.gnome.seahorse;
        sway = {
          enable = true;
          package = null;
        };
        zsh.vteIntegration = true;
      };

      qt = {
        enable = mkDefault true;
        platformTheme = mkDefault null; # qt5 and qt6 config expect this.
        style = mkDefault null; # qt5 and qt6 config expect this.
      };

      security = {
        polkit.enable = true;
      };

      services = {
        accounts-daemon.enable = true;
        avahi.enable = mkDefault true;

        dbus = {
          enable = true;
          packages = [pkgs.gcr];
        };

        gnome = {
          # core-developer-tools.enable = true;
          core-os-services.enable = false;
          core-utilities.enable = true;
          evolution-data-server.enable = mkDefault true;
          games.enable = true;

          glib-networking.enable = true;
          gnome-initial-setup.enable = false;
          gnome-keyring.enable = true;
          gnome-online-accounts.enable = mkDefault true;
          gnome-settings-daemon.enable = true;
          sushi.enable = notExcluded pkgs.gnome.sushi;
          localsearch.enable = mkDefault true;
          tinysparql.enable = mkDefault true;
        };

        gvfs.enable = true;

        hardware.bolt.enable = mkDefault true;

        libinput.enable = mkDefault true;

        power-profiles-daemon.enable = mkDefault true;

        system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);

        udev.packages = with pkgs; [gnome-settings-daemon];

        udisks2.enable = true;

        upower.enable = config.powerManagement.enable;

        xfs.enable = false;

        xserver = {
          desktopManager.gnome.enable = false;
            displayManager = {
              gdm = {
                enable = mkDefault true;
                wayland = true;
              };
            };
          enable = true; # xwayland
          updateDbusEnvironment = true;
        };


        displayManager = {
          defaultSession = mkDefault "sway-gnome";
          sessionPackages = [sway-gnome-desktop];
        };
      };

      systemd = {
        packages = [sway-gnome-desktop];

        user.services = {
          polkit-gnome-authentication-agent-1 = {
            unitConfig = {
              Description = "polkit-gnome-authentication-agent-1";
              Wants = ["graphical-session.target"];
              WantedBy = ["graphical-session.target"];
              After = ["graphical-session.target"];
            };

            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
          };
        };
      };

      xdg.icons.enable = true;
      xdg.mime.enable = true;

      xdg.portal = {
        config = {
          sway = {
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };
        };
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
        wlr.enable = true;
      };
    };
  }
