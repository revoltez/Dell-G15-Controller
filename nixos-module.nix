self:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.dell-g15-controller;
in
{
  options.programs.dell-g15-controller = {
    enable = lib.mkEnableOption "Dell G15 Controller";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "dell-g15-controller.packages.\${system}.default";
      description = "The Dell G15 Controller package to use.";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "alice" ];
      description = ''
        Users to add to the `plugdev` group. Required for the USB keyboard
        backlight control to work without root.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # `plugdev` group + udev rule for the AlienFX USB controller (187c:0550).
    users.groups.plugdev = { };
    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = [ "plugdev" ];
    });

    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="187c", ATTRS{idProduct}=="0550", MODE="0660", GROUP="plugdev", SYMLINK+="awelc"
    '';

    # Power-mode / fan / G-mode control writes to /proc/acpi/call.
    boot.kernelModules = [ "acpi_call" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

    # The app elevates via pkexec.
    security.polkit.enable = true;
  };
}
