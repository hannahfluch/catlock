{
  lib,
  writeShellApplication,
  quickshell,
  qt6,
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

    export QML_IMPORT_PATH="${qt6.qtmultimedia}/${qt6.qtbase.qtQmlPrefix}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
    export QT_PLUGIN_PATH="${qt6.qtmultimedia}/${qt6.qtbase.qtPluginPrefix}''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"

    exec quickshell --no-duplicate --path ${./qml}/shell.qml "$@"
  '';
  meta = {
    description = "A spinning cat Wayland lock screen";
    mainProgram = "catlock";
    platforms = lib.platforms.linux;
  };
}
