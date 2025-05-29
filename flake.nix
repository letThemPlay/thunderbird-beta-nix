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
        { pkgs, ... }:

        {
          packages =
            let
              thunderbird-bin-unwrapped = pkgs.thunderbird-bin-unwrapped.override {
                generated = builtins.fromJSON (builtins.readFile "${self}/beta-sources.json");
              };

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
