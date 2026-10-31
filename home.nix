{
  config,
  pkgs,
  lib,
  inputs,
  imports,
  ...
}: let
  configDirectory = "${config.home.homeDirectory}/nixos_configs/configs";
in {
  home.username = "vstankov";
  home.homeDirectory = "/home/vstankov";

  imports = [./plasma.nix];

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

  programs.vicinae = {
    # Schema: https://www.vicinae.com/schemas/config.json
    # Default Config: `vicinae config default`

    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
    };
  };

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

    initContent = lib.mkOrder 1500 ''
      function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          command yazi "$@" --cwd-file="$tmp"
          IFS= read -r -d \'\' cwd < "$tmp"
          [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
      }

      export EDITOR=nvim
      eval "$(direnv hook zsh)"
      export PATH=$PATH:~/bin
    '';

    profileExtra = ''
      export PATH=$PATH:~/bin
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
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
