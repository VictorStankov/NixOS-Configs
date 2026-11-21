{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  glib-networking,
  libsecret,
  webkitgtk_4_1,
  gtk3,
  libsoup_3,
  dbus,
  cairo,
  gdk-pixbuf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "voltius";
  version = "0.79.0";

  src = fetchurl {
    url = "https://github.com/VoltiusApp/voltius/releases/download/v${finalAttrs.version}/Voltius_${finalAttrs.version}_amd64.deb";
    hash = "sha256-rmSXULuh0osgWSaZ6FQ00+GeOMSunsOqbevsIIDNKeA=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    libsecret
    webkitgtk_4_1
    gtk3
    libsoup_3
    dbus
    cairo
    gdk-pixbuf
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    runHook postInstall
  '';

  meta = {
    description = "Open-Source SSH & SFTP Client";
    homepage = "https://voltius.app";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "voltius";
  };
})
