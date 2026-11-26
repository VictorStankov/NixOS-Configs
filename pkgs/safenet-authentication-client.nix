{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  pango,
  gdk-pixbuf,
  glib,
  libX11,
  openssl,
  pcsclite,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "safenet-authentication-client";
  version = "10.9.6747";

  src = fetchurl {
    url = "https://www.b-trust.bg/attachments/BtrustPrivateFile/251/docs/Gemalto-Linux.tar";
    hash = "sha256-FmMeC5MF8AwRNQzpDLDECR11tj2FdzpHwb0Hq8ZsfTI=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    pango
    gdk-pixbuf
    glib
    libX11
    openssl
    pcsclite
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    tar xf $src
    dpkg-deb -x Gemalto-Linux/Ubuntu-2204/safenetauthenticationclient_${finalAttrs.version}_amd64.deb .
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    $CC -shared -fPIC -O2 -o libsac-procfix.so ${./safenet-procfix.c} -ldl
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* etc $out/
    install -m755 libsac-procfix.so $out/lib/
    cp -r lib/systemd $out/lib/

    # The icons ship loose in share/icons, which icon themes don't look at
    mv $out/share/icons $out/share/pixmaps

    for f in $out/share/applications/*.desktop $out/etc/xdg/autostart/*.desktop $out/lib/systemd/system/*.service; do
      substituteInPlace $f --replace-fail /usr/bin $out/bin
    done
    runHook postInstall
  '';

  # The GUIs load resources embedded in their own executable via argv[0], so
  # point it at the real binary instead of the wrapper
  dontWrapGApps = true;
  postFixup = ''
    for b in SACTools SACMonitor; do
      wrapProgram $out/bin/$b "''${gappsWrapperArgs[@]}" \
        --argv0 $out/bin/.$b-wrapped \
        --prefix LD_PRELOAD : $out/lib/libsac-procfix.so
    done
  '';

  meta = {
    description = "SafeNet Authentication Client, PKCS#11 middleware for Gemalto/Thales smart cards and tokens";
    homepage = "https://www.b-trust.bg/";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "SACTools";
  };
})
