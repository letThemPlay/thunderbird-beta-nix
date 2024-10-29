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
          packages.thunderbird = pkgs.wrapFirefox (pkgs.thunderbird-unwrapped.overrideAttrs rec {
            version = "132.0b6";
            src = pkgs.fetchurl {
              url = "mirror://mozilla/thunderbird/releases/${version}/source/thunderbird-${version}.source.tar.xz";
              sha256 = "sha256-wRWLOIwnLesfnonav3oGRWiWwCvnfWeu5uC52jtAZkE=";
            };
          }) { libName = "thunderbird"; };

          packages.default =
            pkgs.wrapThunderbird
              (pkgs.thunderbird-bin-unwrapped.override {
                generated = {
                  version = "132.0b6";
                  sources = [
                    {
                      url = "https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/132.0b6/linux-x86_64/en-US/thunderbird-132.0b6.tar.bz2";
                      arch = "linux-x86_64";
                      locale = "en-US";
                      sha256 = "sha256-So0FdYfrd+PzTsW4mQbxyeS5osvKfPUHW4azffvpGKk=";
                    }
                  ];
                };
              })
              {
                applicationName = "thunderbird";
                pname = "thunderbird-bin";
                desktopName = "Thunderbird";
              };

          packages.update =
            let
              name = "update";
              buildInputs = [
                pkgs.curl
                pkgs.jq
                pkgs.jo
              ];
              update-script = (pkgs.writeScriptBin name (builtins.readFile ./update.sh)).overrideAttrs (prev: {
                buildCommand = "${prev.buildCommand}\n patchShebangs $out";
              });
            in
            pkgs.symlinkJoin {
              inherit name;
              paths = [ update-script ] ++ buildInputs;
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
            };

          packages.update-versions = pkgs.writeShellScriptBin "update-versions" ''
            content=$(${pkgs.curl}/bin/curl https://product-details.mozilla.org/1.0/thunderbird_versions.json)
            beta_version=$( ${pkgs.jq}/bin/jq -r '.LATEST_THUNDERBIRD_DEVEL_VERSION' <<< "$content" )

            url=https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/$beta_version/linux-x86_64/en-US/thunderbird-$beta_version.tar.bz2
            hash=$(nix-prefetch-url $url)

            jo version="$beta_version" sources=$(jo -a $(jo url="$url" arch="linux-x86_64" locale="en-US" sha256="$hash")) > generated.json
          '';
        };
    };
}
