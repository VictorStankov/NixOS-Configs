{
  config,
  pkgs,
  ...
}: {
  home.username = "vstankov";
  home.homeDirectory = "/home/vstankov";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    brave
    discord
    spotify
    steam
    bitwarden-desktop
    rustdesk-flutter

    slack
    teams-for-linux
    jetbrains.pycharm
    jetbrains.datagrip
    opentofu
    awscli2
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;

    settings.user = {
      name = "VictorStankov";
      email = "64612982+VictorStankov@users.noreply.github.com";
    };
  };

  programs.zsh = {
    enable = true;

    shellAliases = {
      ll = "ls -la";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = ["git"];
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };
  xdg.configFile = {
    "nvim/init.vim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nvim/init.vim";
      force = true;
    };
    "hypr/hyprland.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/hyprland/hyprland.lua";
      force = true;
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";
}
