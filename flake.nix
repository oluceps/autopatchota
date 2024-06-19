{
  nixConfig = {
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    extra-substituters = "https://cache.garnix.io";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = (with inputs; [ devshell.flakeModule ]);
        debug = false;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem =
          {
            pkgs,
            lib,
            system,
            ...
          }:
          {
            devshells.default.devshell = {
              packages =
                (with pkgs; [
                  just
                  nushell
                  ouch

                ])
                ++ lib.singleton inputs.oluceps.packages.${system}.avbroot;
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    oluceps.url = "github:oluceps/nixos-config";
  };
}
