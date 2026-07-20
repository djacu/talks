{
  lib,
  stdenvNoCC,
  lato,
  atkinson-hyperlegible-next,
  atkinson-hyperlegible-mono,
}:
stdenvNoCC.mkDerivation {

  name = baseNameOf ./.;

  dontUnpack = true;

  # A self-contained reveal.js theme: CSS plus the exact font weights the
  # theme references, so a deck that copies $out/ works offline.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/fonts
    cp ${./theme.css} $out/theme.css
    cp ${./highlight.css} $out/highlight.css
    cp -r ${./looks} $out/looks

    cp ${lato}/share/fonts/lato/Lato-Regular.ttf $out/fonts/
    cp ${lato}/share/fonts/lato/Lato-Bold.ttf $out/fonts/

    cp ${atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext-Regular.ttf $out/fonts/
    cp ${atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext-Bold.ttf $out/fonts/
    cp ${atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext-Italic.ttf $out/fonts/
    cp ${atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext-BoldItalic.ttf $out/fonts/

    cp ${atkinson-hyperlegible-mono}/share/fonts/truetype/AtkinsonHyperlegibleMono-Regular.ttf $out/fonts/
    cp ${atkinson-hyperlegible-mono}/share/fonts/truetype/AtkinsonHyperlegibleMono-Bold.ttf $out/fonts/

    runHook postInstall
  '';

  meta = {
    description = "Light NixOS-branded reveal.js theme (theme + highlight + fonts)";
    platforms = lib.platforms.all;
  };

}
