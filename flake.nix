{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { pkgs, ... }:
        {
          packages.default = pkgs.thunderbird-bin.overrideAttrs (_: rec {
            version = "132.0b6";
            src =
              pkgs.fetchurl {
                url = "https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/${version}/linux-x86_64/en-US/thunderbird-${version}.tar.bz2";
                sha256 = "sha256-So0FdYfrd+PzTsW4mQbxyeS5osvKfPUHW4azffvpGKk=";
              };
          });
        };
    };
}
