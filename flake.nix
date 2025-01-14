{
  description = "Nix Flake for Thunderbird-beta";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs self; } {
      systems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"aarch64-darwin"
        #"x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          lib,
          ...
        }:

        {
          packages =
            let
              thunderbird-bin-unwrapped =
                (pkgs.thunderbird-bin-unwrapped.override {
                  generated = builtins.fromJSON (builtins.readFile "${self}/beta-sources.json");
                }).overrideAttrs
                  (
                    final: prev:
                    let
                      systemLocale = "en_US";
                      generated = builtins.fromJSON (builtins.readFile "${self}/beta-sources.json");
                      inherit (generated) sources version;

                      mozillaPlatforms = {
                        i686-linux = "linux-i686";
                        x86_64-linux = "linux-x86_64";
                      };

                      mozLocale =
                        if systemLocale == "ca_ES@valencia" then
                          "ca-valencia"
                        else
                          lib.replaceStrings [ "_" ] [ "-" ] systemLocale;

                      arch = mozillaPlatforms.${pkgs.stdenv.hostPlatform.system};
                      isPrefixOf = prefix: string: builtins.substring 0 (builtins.stringLength prefix) string == prefix;
                      sourceMatches = locale: source: (isPrefixOf source.locale locale) && source.arch == arch;
                      defaultSource = lib.findFirst (sourceMatches "en-US") { } sources;
                      source = lib.findFirst (sourceMatches mozLocale) defaultSource sources;
                    in
                    {
                      inherit version;

                      src = pkgs.fetchurl {
                        inherit (source) url sha256;
                      };
                    }
                  );

              thunderbird-bin = pkgs.wrapThunderbird thunderbird-bin-unwrapped {
                applicationName = "thunderbird";
                pname = "thunderbird-bin";
                desktopName = "Thunderbird";
              };
            in
            {
              inherit thunderbird-bin-unwrapped thunderbird-bin;
              default = thunderbird-bin;

              update =
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
            };
        };
    };
}
