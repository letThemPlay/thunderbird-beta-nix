# Thunderbird Beta for Nix

## Description

A simple flake to allow for installing Thunderbird BETA in NixOS.

Firefox allows for variants using either an overlay provided by mozilla for nightly or packges available directly in nixpkgs; so why not Thunderbird.

The package provides are overrides of nixpkgs using a generated beta sources list; originally I override the non-binary version of thunderbird but that takes a long time to compile and there were still a couple of niggles that wasn't easily overcome with how it was built.

The beta-sources.json is backed by a scheduled workflow that will reguarly check for updates.

## Installation

This guide is assuming a flake setup.

1. Add the input

```
    inputs.thunderbird-beta.url = "github:letthemplay/thunderbird-beta-nix";
```

2. Add the package to your system packages

```
    environment.systemPackages = [ inputs.thunderbird-beta.packages.${pkgs.system}.default ]
```

3. Profit

## Flake Outputs

The flake provides the following outputs

 - thunderbird-bin
 - thunderbird-bin-unwrapped
 - default -> thunderbird-bin

There is an update package also available but that is used in the update workflow.

## TODO

 - [ ] Module For non flake users
 - [ ] Overlay installation
 - [ ] Full locale list
 - [ ] Other variants if requested
