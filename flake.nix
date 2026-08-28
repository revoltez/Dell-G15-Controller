{
  description = "Dell G15 Controller — control keyboard backlight, power modes and fans on Dell G15 laptops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # This is an x86_64 laptop app; only that system is meaningful.
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        default = self.packages.${system}.dell-g15-controller;
        dell-g15-controller = pkgs.callPackage ./package.nix { };
      };

      # `nix run` support.
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/dell-g15-controller";
      };

      # Import this into your ~/nixos configuration.
      nixosModules.default = import ./nixos-module.nix self;

      # `nix develop` — replacement for the old shell.nix.
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.default ];
        packages = with pkgs; [
          (python3.withPackages (ps: with ps; [
            pyside6
            pexpect
            pyusb
          ]))
        ];
        shellHook = ''
          # pkexec (setuid) lives here on NixOS.
          export PATH="/run/wrappers/bin:$PATH"
          echo "dev shell ready — run: python main.py"
        '';
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
