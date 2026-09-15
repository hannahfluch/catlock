{
  lib,
  writeShellApplication,
  quickshell,
}:
writeShellApplication {
  name = "catlock";
  runtimeInputs = [ quickshell ];
  text = ''
    case "''${1:-}" in
      --help|-h|--version|-V) exec quickshell "$@" ;;
    esac

    if [[ ! -r /etc/pam.d/cat-lock ]]; then
      echo "catlock: missing /etc/pam.d/cat-lock; refusing to lock." >&2
      echo "Enable programs.catlock.enable with catlock.nixosModules.default and rebuild NixOS first." >&2
      exit 1
    fi

    exec quickshell --no-duplicate --path ${./qml}/shell.qml "$@"
  '';
  meta = {
    description = "A spinning cat Wayland lock screen";
    mainProgram = "catlock";
    platforms = lib.platforms.linux;
  };
}
