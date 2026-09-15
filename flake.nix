{
  description = "A spinning cat Wayland lock screen";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          catlock = pkgs.callPackage ./package.nix { };
        in
        {
          inherit catlock;
          default = catlock;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = nixpkgs.lib.getExe self.packages.${system}.default;
          meta.description = "Lock the screen with a spinning cat";
        };
      });

      nixosModules.default = import ./module.nix;
    };
}
