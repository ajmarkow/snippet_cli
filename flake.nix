{
  description = "Interactively build snippets for Espanso";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # Lets consumers add snippet_cli to nixpkgs and then refer to it by bare
      # name in environment.systemPackages / home.packages, instead of threading
      # `system` through a module to reach packages.${system}.default.
      overlays.default = final: _prev: {
        snippet_cli = final.callPackage ./nix { };
      };

      packages = forAllSystems (pkgs: rec {
        snippet_cli = pkgs.callPackage ./nix { };
        default = snippet_cli;
      });

      apps = forAllSystems (pkgs: rec {
        snippet_cli = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.snippet_cli}/bin/snippet_cli";
          meta.description = "Interactively build snippets for Espanso";
        };
        default = snippet_cli;
      });

      # `nix develop` gives the runtime plus bundix, for regenerating gemset.nix.
      # Day-to-day development uses devenv instead — see devenv.nix.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.ruby
            pkgs.bundix
            pkgs.gum
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
