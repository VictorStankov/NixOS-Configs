# SafeNet Authentication Client for the B-Trust (Gemalto) signing token.
{pkgs, ...}: let
  sac = pkgs.callPackage ../pkgs/safenet-authentication-client.nix {};

  # The card only holds the leaf certificate; without these the chain can't be
  # built, so browsers send an incomplete chain and signatures don't validate
  bTrustRoot = pkgs.fetchurl {
    url = "http://ca.b-trust.org/repository/B-TrustRootQCA.cer";
    hash = "sha256-SzXLKoJh3TT8fHIPRbvCE1zPP0ndZ5tvnkLnlUVeD8w=";
  };
  bTrustOperational = pkgs.fetchurl {
    url = "http://ca.b-trust.org/repository/B-TrustOperationalQCA.cer";
    hash = "sha256-djkfc+dy9tiS+nP2T4nBeWj4/IbnalpWXfsleccC3c4=";
  };
in {
  services.pcscd.enable = true;

  environment.systemPackages = [sac];

  # The binaries read their config from these fixed paths
  environment.etc = {
    "eToken.conf".source = "${sac}/etc/eToken.conf";
    "eToken.common.conf".source = "${sac}/etc/eToken.common.conf";
    "eToken.policy.conf".source = "${sac}/etc/eToken.policy.conf";

    # Lets p11-kit aware programs (GnuTLS, p11tool, ...) find the token
    "pkcs11/modules/safenet.module".text = ''
      module: ${sac}/lib/libeToken.so
    '';
  };

  # libSACUI spawns the PIN dialog from /usr/lib/SAC and SACMonitor opens
  # SACTools from /usr/bin, both hardcoded in the binaries
  systemd.tmpfiles.rules = [
    "L+ /usr/lib/SAC - - - - ${sac}/lib/SAC"
    "L+ /usr/bin/SACTools - - - - ${sac}/bin/SACTools"
  ];

  systemd.packages = [sac];
  systemd.services.SACSrv.wantedBy = ["multi-user.target"];

  programs.firefox.policies.SecurityDevices.SafeNet = "${sac}/lib/libeToken.so";

  # Okular (PDF signing) and Chromium-based browsers read ~/.pki/nssdb.
  # Re-register on every activation so the store path stays current.
  home-manager.users.vstankov = {
    config,
    lib,
    ...
  }: {
    home.activation.safenetNssdb = lib.hm.dag.entryAfter ["writeBoundary"] ''
      db="sql:$HOME/.pki/nssdb"
      run mkdir -p "$HOME/.pki/nssdb"
      [ -f "$HOME/.pki/nssdb/cert9.db" ] || run ${pkgs.nss.tools}/bin/certutil -N -d "$db" --empty-password
      ${pkgs.nss.tools}/bin/modutil -dbdir "$db" -delete SafeNet -force >/dev/null 2>&1 || true
      run ${pkgs.nss.tools}/bin/modutil -dbdir "$db" -add SafeNet -libfile ${sac}/lib/libeToken.so -force

      # Root trusted for signatures only (S/MIME column), not for TLS servers
      run ${pkgs.nss.tools}/bin/certutil -d "$db" -A -n "B-Trust Root Qualified CA" -t ",C," -a -i ${bTrustRoot}
      run ${pkgs.nss.tools}/bin/certutil -d "$db" -A -n "B-Trust Operational Qualified CA" -t ",," -a -i ${bTrustOperational}
    '';

    # Okular's default certificate DB is the Firefox profile, which doesn't
    # have the token (Firefox only loads it at runtime from policy).
    # Okular parses this as a URL (QUrl(...).toLocalFile()), so a bare path
    # becomes "" and it silently falls back to the default DB
    programs.plasma.configFile.okular-generator-popplerrc.Signatures = {
      UseDefaultCertDB = false;
      DBCertificatePath = "file://${config.home.homeDirectory}/.pki/nssdb";
    };
  };
}
