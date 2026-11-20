{config, ...}: let
  repoDirectory = "${config.home.homeDirectory}/nixos_configs";
  configDirectory = "${repoDirectory}/configs";
in {
  xdg.binHome = "${config.home.homeDirectory}/bin";
  xdg.localBinInPath = true;

  home.file."bin/layout-switch" = {
    source = config.lib.file.mkOutOfStoreSymlink "${repoDirectory}/scripts/layout-switch";
    #    executable = true;
    force = true;
  };

  xdg.configFile = {
    "nvim/init.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDirectory}/nvim/init.lua";
      force = true;
    };
    "hypr/hyprland.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDirectory}/hyprland/hyprland.lua";
      force = true;
    };
    "ghostty/config.ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDirectory}/ghostty/config.ghostty";
      force = true;
    };
    "ghostty/auto/theme.ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDirectory}/ghostty/auto/theme.ghostty";
      force = true;
    };
    # Symlinked out of the store so settings changed in the vicinae GUI are written back to the repo.
    "vicinae/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDirectory}/vicinae/settings.json";
      force = true;
    };
  };
}
