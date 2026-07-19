{
  lib,
  reveal-js,
  nixos-reveal-theme,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {

  name = baseNameOf ./.;

  dontUnpack = true;

  # Assemble the deck: reveal.js runtime under dist/, our theme under theme/,
  # slides as index.html. index.html references both with relative paths, so
  # the output opens directly from a file with no server.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ${reveal-js}/dist $out/dist
    cp -r ${nixos-reveal-theme} $out/theme
    cp -r ${./icons} $out/icons
    cp ${./index.html} $out/index.html

    runHook postInstall
  '';

  meta = {
    description = "Slides: Beholden to No One: The Nix Override Ladder (Nix Vegas 2026)";
    platforms = lib.platforms.all;
  };

}
