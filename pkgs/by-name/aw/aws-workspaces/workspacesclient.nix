{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  makeWrapper,
}:

let
  dcv-path = "lib/x86_64-linux-gnu/workspacesclient/dcv";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "workspacesclient";
  version = "2024.8.5191";

  src = fetchurl {
    urls = [
      # Check new version at https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu/dists/jammy/main/binary-amd64/Packages
      "https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu/dists/jammy/main/binary-amd64/workspacesclient_${finalAttrs.version}_amd64.deb"
      "https://d3nt0h4h6pmmc4.cloudfront.net/new_workspacesclient_jammy_amd64.deb"
    ];
    hash = "sha256-BDxMycVgWciJZe8CtElXaWVnqYDQO5NmawK10GvP2+k=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r usr/* $out

    echo $src >> "$out/share/workspace_dependencies.pin"

    # remove all libraries provided by the FHS
    find $out/${dcv-path} -name lib\* ! -name libdcv\* ! -name libgioopenssl\* | xargs rm

    # dcvclient sets up the environment wrong. Instead wrap the binary directly with the environment variables not already provided by the FHS
    mv $out/${dcv-path}/dcvclientbin $out/${dcv-path}/dcvclient
    wrapProgram $out/${dcv-path}/dcvclient \
      --suffix LD_LIBRARY_PATH : $out/${dcv-path} \
      --suffix GIO_EXTRA_MODULES : ${dcv-path}/gio/modules \
      --set DCV_SASL_PLUGIN_DIR $out/${dcv-path}/sasl2 \

    runHook postInstall
  '';

  meta = {
    description = "Client for Amazon WorkSpaces, a managed, secure Desktop-as-a-Service (DaaS) solution";
    homepage = "https://clients.amazonworkspaces.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "workspacesclient";
    maintainers = with lib.maintainers; [
      mausch
      dylanmtaylor
    ];
    platforms = [ "x86_64-linux" ]; # TODO Mac support
  };
})
