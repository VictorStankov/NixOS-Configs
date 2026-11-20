{...}: {
  # Only public keys are tracked; private keys must be copied into ~/.ssh manually.
  # force: replace the identical, manually copied files already in ~/.ssh.
  home.file.".ssh/personal.pub" = {
    source = ../keys/personal.pub;
    force = true;
  };
  home.file.".ssh/work.pub" = {
    source = ../keys/work.pub;
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
}
