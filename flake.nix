{
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
            ...
          }:
          {
            devshells.default.devshell = {
              packages = (
                with pkgs;
                [
                  just
                  nushell
                  ouch
                  avbroot
                ]
              );
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
