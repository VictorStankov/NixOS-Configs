{
  config,
  pkgs,
  lib,
  inputs,
  imports,
  ...
}: let
  repoDirectory = "${config.home.homeDirectory}/nixos_configs";
  configDirectory = "${repoDirectory}/configs";

  personalGit = {
    name = "VictorStankov";
    email = "64612982+VictorStankov@users.noreply.github.com";
    signingKey = "~/.ssh/personal.pub";
  };

  workGit = {
    name = "V-Stankov";
    email = "173147716+V-Stankov@users.noreply.github.com";
    signingKey = "~/.ssh/work.pub";
  };
in {
  home.username = "vstankov";
  home.homeDirectory = "/home/vstankov";

  imports = [./plasma.nix];

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

  programs.git = {
    enable = true;

    settings.user = {
      inherit (personalGit) name email;
    };

    signing = {
      format = "ssh";
      key = personalGit.signingKey;
      signByDefault = true;
      allowedSigners = ''
        ${personalGit.email} ${lib.trim (builtins.readFile ./keys/personal.pub)}
        ${workGit.email} ${lib.trim (builtins.readFile ./keys/work.pub)}
      '';
    };

    # Repos cloned through the `work` SSH host alias use the work identity.
    # Both `work:` and `git@work:` remote URL forms are matched.
    includes =
      map (condition: {
        inherit condition;
        contents.user = {
          inherit (workGit) name email;
          signingKey = workGit.signingKey;
        };
      }) [
        "hasconfig:remote.*.url:git@work:*/**"
      ];
  };

  # Only public keys are tracked; private keys must be copied into ~/.ssh manually.
  # force: replace the identical, manually copied files already in ~/.ssh.
  home.file.".ssh/personal.pub" = {
    source = ./keys/personal.pub;
    force = true;
  };
  home.file.".ssh/work.pub" = {
    source = ./keys/work.pub;
    force = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/personal";
        IdentitiesOnly = true;
      };
      # Clone work repos as `work:Org/repo.git`.
      "work" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/work";
        IdentitiesOnly = true;
      };
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
