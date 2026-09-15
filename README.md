# catlock

Spinning cat lock screen for wayland.

## Installation

Using nix flakes:

```nix
inputs.catlock = {
  url = "github:hannahfluch/catlock";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add `catlock` to your outputs arguments. Import and enable its NixOS module in
your `nixosSystem.modules` list to install the package and password-auth service:

```nix
catlock.nixosModules.default
{ programs.catlock.enable = true; }
```

## GIF

`qml/cat.gif` is the 480×480 transparent GIF from
[this Tenor post](https://tenor.com/view/spinning-cat-gif-9797848010913001046),
downloaded from https://media.tenor.com/h_jy2s28rlYAAAAi/spinning-cat.gif.
Replace it and rebuild to change the cat.
