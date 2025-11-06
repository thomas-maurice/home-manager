{ config, pkgs, lib, ... }:

let
  # Enable declarative asdf management (set to false to manage .tool-versions manually)
  enableDeclarativeAsdf = false;

  # Define asdf tools here - only used if enableDeclarativeAsdf = true
  asdfTools = {
    terraform = "1.13.4";
    vault = "1.20.4";
  };

  # Generate .tool-versions content from the mapping
  toolVersionsContent = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (plugin: version: "${plugin} ${version}") asdfTools);

  # Generate plugin installation commands
  pluginInstallCommands = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (plugin: version: ''
      if ! asdf plugin list | grep -q "^${plugin}$"; then
        echo "Adding ${plugin} plugin..."
        $DRY_RUN_CMD asdf plugin add ${plugin} || true
      fi
    '') asdfTools);
in
{
  # Install asdf-vm
  home.packages = with pkgs; [
    asdf-vm
  ];

  # Declarative tool versions configuration (only if enabled)
  home.file.".tool-versions" = lib.mkIf enableDeclarativeAsdf {
    text = toolVersionsContent;
  };

  # Automatically install asdf plugins and versions (only if enabled)
  home.activation.installAsdfTools = lib.mkIf enableDeclarativeAsdf (
    config.lib.dag.entryAfter ["writeBoundary"] ''
      if [ -f "$HOME/.nix-profile/share/asdf-vm/asdf.sh" ]; then
        export ASDF_DIR="$HOME/.nix-profile/share/asdf-vm"
        export ASDF_DATA_DIR="''${ASDF_DATA_DIR:-$HOME/.asdf}"
        . "$HOME/.nix-profile/share/asdf-vm/asdf.sh"

        echo "Setting up asdf tools..."

        # Install plugins if not already installed
        ${pluginInstallCommands}

        # Install versions from .tool-versions
        cd "$HOME"
        $DRY_RUN_CMD asdf install || echo "asdf install completed with status $?"
      else
        echo "asdf-vm not found, skipping tool installation"
      fi
    ''
  );
}
