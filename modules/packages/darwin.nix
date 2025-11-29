{ config, pkgs, ... }:

let
  # Import GUI packages list
  guiPackages = import ./gui.nix { inherit pkgs; };
in
{
  # macOS-only packages
  home.packages =
    with pkgs;
    [
      mongodb-compass
      slack
      spotify
      vscode
    ]
    ++ guiPackages;

  # Use the official targets.darwin.copyApps
  targets.darwin.copyApps = {
    enable = true;
    directory = "Applications/Home Manager Apps";
    enableChecks = false; # Disable permission checks (not recommended)
  };

  # Disable linkApps (conflicts with copyApps)
  targets.darwin.linkApps.enable = false;
}
