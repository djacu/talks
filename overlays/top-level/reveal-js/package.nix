{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {

  pname = baseNameOf ./.;
  version = "6.0.1";

  # reveal.js commits its prebuilt dist/ directory, so no npm or bundler step is
  # needed. dist/ is the complete runtime artifact: it holds the UMD/ESM builds,
  # themes, and built plugins (the notes plugin even inlines the speaker view),
  # so decks reference only dist/. The top-level plugin/ dir is build-time
  # TypeScript source and is not installed.
  src = fetchFromGitHub {
    owner = "hakimel";
    repo = "reveal.js";
    rev = finalAttrs.version;
    hash = "sha256-J0CeWxL0Gs/1pOgszHUYgSl1+9nXibgb3fNyDVMr2OQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist $out/dist

    runHook postInstall
  '';

  meta = {
    description = "HTML presentation framework (prebuilt dist/ and plugin/)";
    homepage = "https://revealjs.com";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };

})
