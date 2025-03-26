{
  stdenv,
  lib,
  callPackage,
  buildFHSEnv,
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
let
  aws-workspaces = callPackage ./aws-workspaces.nix { };
  # To remove when https://github.com/NixOS/nixpkgs/pull/345659 has landed
  custom_jbigkit = callPackage ./jbigkit.nix { };

  # Source: https://github.com/jthomaschewski/pkgbuilds/pull/3
  # Credits to https://github.com/rwolfson
  custom_lsb_release = writeShellApplication {
    name = "lsb_release";

    text = ''
      # "Fake" lsb_release script
      # This only exists so that "lsb_release -r" will return the below string
      # when placed in the $PATH

      if [ "$#" -ne 1 ] || [ "$1" != "-r" ] ; then
          echo "Expected only '-r' argument"
          exit 1
      fi

      echo "Release: 22.04"
    '';
  };
in
buildFHSEnv {
  pname = "aws-workspaces";
  inherit (aws-workspaces) version;

  runScript = "${aws-workspaces}/bin/workspacesclient";

  includeClosures = true;

  targetPkgs =
    pkgs:
    with pkgs;
    [
      aws-workspaces
      custom_lsb_release
      (lib.getLib stdenv.cc.cc)
      atk
      cairo
      curl
      custom_jbigkit
      ffmpeg_6.lib
      gdk-pixbuf
      glib
      glib-networking
      graphicsmagick_q16
      gsettings-desktop-schemas
      gtk3
      hiredis
      icu70
      libfido2
      libkrb5
      libpulseaudio
      librsvg
      libsoup_3
      libtiff
      libusb1
      libva
      libpsl
      libvdpau
      lmdb
      lttng-ust
      openssl
      pango
      publicsuffixList
      pcsclite
      protobufc
      sssd
      webkitgtk_4_1
      xorg.libxcb
      zlib
    ];

  meta = aws-workspaces.meta;
}
