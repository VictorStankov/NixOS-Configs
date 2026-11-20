{lib, ...}: let
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
        ${personalGit.email} ${lib.trim (builtins.readFile ../keys/personal.pub)}
        ${workGit.email} ${lib.trim (builtins.readFile ../keys/work.pub)}
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
}
