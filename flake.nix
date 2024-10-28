{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  nixConfig = {
    extra-substituters = [
      "https://letthemplaycache.cachix.org"
    ];

    extra-trusted-public-keys = [
      "letthemplaycache.cachix.org-1:Vk354ZqC4+Wwq0+yp1xWm9jlaAmjcXNkhvIKYbO5ptM="
    ];
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
          packages.default = pkgs.wrapFirefox (pkgs.thunderbird-unwrapped.overrideAttrs rec {
            version = "132.0b6";
            src = pkgs.fetchurl {
              url = "mirror://mozilla/thunderbird/releases/${version}/source/thunderbird-${version}.source.tar.xz";
              sha256 = "sha256-wRWLOIwnLesfnonav3oGRWiWwCvnfWeu5uC52jtAZkE=";
            };
          }) { libName = "thunderbird"; };
        };
    };
}
