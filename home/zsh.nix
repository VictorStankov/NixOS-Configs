{lib, ...}: {
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
}
