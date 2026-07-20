{
  lib,
  stdenvNoCC,
  decktape,
  makeFontsConf,
  lato,
  atkinson-hyperlegible-next,
  atkinson-hyperlegible-mono,
  beholden-to-no-one,
}:
stdenvNoCC.mkDerivation {

  name = baseNameOf ./.;

  dontUnpack = true;

  nativeBuildInputs = [ decktape ];

  # Export the reveal.js deck to a single self-contained PDF (one page per
  # slide) with decktape, a headless-browser driver. Useful as a portable
  # fallback for machines where you can't open the HTML deck.
  #
  # Headless chromium needs a fontconfig to render any text in the build
  # sandbox; without it the PDF comes out blank. Point it at a generated
  # fonts.conf carrying the deck's fonts.
  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export FONTCONFIG_FILE="${
      makeFontsConf {
        fontDirectories = [
          lato
          atkinson-hyperlegible-next
          atkinson-hyperlegible-mono
        ];
      }
    }"

    decktape \
      --chrome-arg=--no-sandbox \
      --chrome-arg=--disable-dev-shm-usage \
      reveal "file://${beholden-to-no-one}/index.html" talk.pdf

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp talk.pdf $out/talk.pdf
    runHook postInstall
  '';

  meta = {
    description = "Beholden to No One deck exported to PDF via decktape";
    platforms = lib.platforms.linux;
  };

}
