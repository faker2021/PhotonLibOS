{
  description =
    "Photon is a high-efficiency LibOS framework, based on a set of carefully selected C++ libs.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";

    vitalpkgs.url = "github:nixvital/vitalpkgs";
    vitalpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    inputs.utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.vitalpkgs.overlay (final: prev: { }) ];
          config.allowUnfree = true;
        };
      in rec {
        devShell = pkgs.mkShell.override { stdenv = pkgs.stdenv; } rec {
          name = "photonlibos";

          packages = with pkgs; [
            # Development Tools
            gcc
            cmake
            cmakeCurses
            vscode-include-fix
            nixpkgs-fmt
            cmake-format

            # Development time dependencies
            gtest

            # Build time and Run time dependencies
            openssl
            zlib
            curl
            libaio
            ninja
          ];

          shellHook = let icon = "f121";
          in ''
            export PS1="$(echo -e '\u${icon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
            alias cmake_debug='cmake -DCMAKE_BUILD_TYPE=Debug ..'
          '';
        };

      });
}
