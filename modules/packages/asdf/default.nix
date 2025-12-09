{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Enable declarative asdf management (set to false to manage .tool-versions manually)
  enableDeclarativeAsdf = false;

  # Define asdf tools here - only used if enableDeclarativeAsdf = true
  asdfTools = {
    terraform = "1.13.4";
    vault = "1.20.4";
  };

  # Generate .tool-versions content from the mapping
  toolVersionsContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (plugin: version: "${plugin} ${version}") asdfTools
  );

  # Generate plugin installation commands
  pluginInstallCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (plugin: version: ''
      if ! asdf plugin list | grep -q "^${plugin}$"; then
        echo "Adding ${plugin} plugin..."
        $DRY_RUN_CMD asdf plugin add ${plugin} || true
      fi
    '') asdfTools
  );
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
}
