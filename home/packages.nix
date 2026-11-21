{pkgs, ...}: {
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    brave
    discord
    vesktop
    telegram-desktop
    spotify
    bitwarden-desktop
    rustdesk-flutter
    qalculate-qt
    libreoffice
    lutris
    prismlauncher
    lazygit
    tmux
    localsend

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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };
}
