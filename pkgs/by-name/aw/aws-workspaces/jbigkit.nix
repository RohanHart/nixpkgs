{
  stdenv,
  lib,
  fetchpatch,
  jbigkit,
}:

jbigkit.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches ++ [
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/jbigkit/-/raw/main/jbigkit-2.1-shared_lib.patch";
      hash = "sha256-+efeeKg3FJ/TjSOj58kD+DwnaCm3zhGzKLfUes/d5rg=";
    })
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/jbigkit/-/raw/main/jbigkit-2.1-ldflags.patch";
      hash = "sha256-ik3NifyuhDHnIMTrNLAKInPgu2F5u6Gvk9daqrn8ZhY=";
    })
    # Archlinux patch: update coverity
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/jbigkit/-/raw/main/jbigkit-2.1-coverity.patch";
      hash = "sha256-APm9A2f4sMufuY3cnL9HOcSCa9ov3pyzgQTTKLd49/E=";
    })
    # Archlinux patch: fix build warnings
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/jbigkit/-/raw/main/jbigkit-2.1-build_warnings.patch";
      hash = "sha256-lDEJ1bvZ+zR7K4CiTq+aXJ8PGjILE3W13kznLLlGOOg=";
    })
  ];

  makeFlags = [
    "AR=${lib.getBin stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}ar"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "DESTDIR=${placeholder "out"}"
    "RANLIB=${lib.getBin stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}ranlib"
  ];

  installPhase = ''
    runHook preInstall

    install -vDm 644 libjbig/*.h -t "$out/include/"
    install -vDm 755 pbmtools/{jbgtopbm{,85},pbmtojbg{,85}} -t "$out/bin/"
    install -vDm 644 pbmtools/*.1* -t "$out/share/man/man1/"

    install -vDm 755 libjbig/*.so.* -t "$out/lib/"
    for lib in libjbig.so libjbig85.so; do
      ln -sv "$lib.${oldAttrs.version}" "$out/lib/$lib"
      ln -sv "$out/lib/$lib.${oldAttrs.version}" "$out/lib/$lib.0"
    done

    runHook postInstall
  '';
})
