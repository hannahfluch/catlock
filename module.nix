{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.catlock.enable = lib.mkEnableOption "the spinning cat lock screen";

  config = lib.mkIf config.programs.catlock.enable {
    environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];

    # Password-only authentication: no invisible fingerprint prompts.
    security.pam.services.cat-lock.fprintAuth = false;
  };
}
