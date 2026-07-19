{
  lib,
  reveal-js,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {

  name = baseNameOf ./.;

  dontUnpack = true;

  # Assemble the deck: reveal.js runtime under dist/, our slides as index.html
  # next to it. index.html references everything with paths relative to dist/,
  # so the output opens directly from a file with no server.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ${reveal-js}/dist $out/dist
    cp ${./index.html} $out/index.html

    runHook postInstall
  '';

  meta = {
    description = "Slides: Beholden to No One: The Nix Override Ladder (Nix Vegas 2026)";
    platforms = lib.platforms.all;
  };

}
