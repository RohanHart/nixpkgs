{
  stdenv,
  lib,
  libpsl,
  dpkg,
  fetchurl,
  autoPatchelfHook,
  curl,
  libkrb5,
  lttng-ust,
  libpulseaudio,
  openssl,
  icu70,
  librsvg,
  gdk-pixbuf,
  libsoup_3,
  glib-networking,
  gsettings-desktop-schemas,
  graphicsmagick_q16,
  libva,
  libusb1,
  hiredis,
  pcsclite,
  jbigkit,
  libvdpau,
  libtiff,
  ffmpeg_6,
  lmdb,
  protobufc,
  zlib,
  cairo,
  fontconfig,
  pango,
  publicsuffixList ? (import <nixpkgs> {}).publicsuffix-list,
  xorg,
  libfido2,
  webkitgtk_4_1,
  copyDesktopItems,
  atk,
  fetchpatch,
  glib,
  sssd,
  gtk3,
  writeShellApplication,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "workspacesclient";

  version = "2024.8.5191";

  src = fetchurl {
    urls = [
      # Check new version at https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu/dists/jammy/main/binary-amd64/Packages
      "https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu/dists/jammy/main/binary-amd64/${finalAttrs.pname}_${finalAttrs.version}_amd64.deb"
      "https://d3nt0h4h6pmmc4.cloudfront.net/new_workspacesclient_jammy_amd64.deb"
    ];
    hash = "sha256-BDxMycVgWciJZe8CtElXaWVnqYDQO5NmawK10GvP2+k=";
  };

  nativeBuildInputs = [
    dpkg
  ];

  installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r usr/* $out

      echo $src >> "$out/share/workspace_dependencies.pin"

      rm $out/lib/x86_64-linux-gnu/workspacesclient/dcv/libgio-2.0.so.0
      ln -s $out/lib/x86_64-linux-gnu/workspacesclient/dcv/* $out/lib/

      runHook postInstall
  '';

  meta = {
    description = "Client for Amazon WorkSpaces, a managed, secure Desktop-as-a-Service (DaaS) solution";
    homepage = "https://clients.amazonworkspaces.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    mainProgram = "workspacesclient";
    maintainers = with lib.maintainers; [
      mausch
      dylanmtaylor
    ];
    platforms = ["x86_64-linux"]; # TODO Mac support
  };
})
