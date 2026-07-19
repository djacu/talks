# nixos-reveal-theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable light-background, NixOS-branded reveal.js theme package (`nixos-reveal-theme`) with a matching custom highlight.js code theme, and switch the `beholden-to-no-one` deck onto it.

**Architecture:** A new top-level Nix package assembles a self-contained theme: a hand-authored `theme.css` (reveal `--r-*` variables + the rule set that consumes them), a hand-authored `highlight.css` (highlight.js token colors), and bundled TTF fonts copied from nixpkgs, referenced by relative `@font-face` URLs. The talk deck depends on the package, copies it into `theme/`, and points its two stylesheet `<link>`s at it. Exact colors are tuned live against rendered screenshots.

**Tech Stack:** Nix (stdenvNoCC), reveal.js 6.0.1 (already packaged as `reveal-js`), CSS with native OKLCH colors, headless Firefox for render verification.

## Global Constraints

- **Theme is LIGHT** (near-white background); the user has projector legibility trouble with dark backgrounds.
- **Palette = official `@nixos/branding` v0.1.0 OKLCH values**, usable in CSS unchanged: NixOS dark blue `oklch(0.55 0.12 264)`, NixOS light blue `oklch(0.75 0.09 240)`; emphasis accent chinese-magenta `oklch(0.55 0.11 330)`; string green `oklch(0.50 0.10 152)`, number orange `oklch(0.55 0.11 54)`, title violet `oklch(0.50 0.11 288)`, attr blue `oklch(0.55 0.11 240)`.
- **Fonts from nixpkgs (all OFL), bundled offline as TTF:** Lato (headings), `atkinson-hyperlegible-next` (body), `atkinson-hyperlegible-mono` (code). Reference via relative `fonts/*.ttf`, `format('truetype')`.
- **All colors are STARTING POINTS**, tuned live in Task 3 against screenshots.
- **Deck must open from `file://` with no web server** (classic UMD includes are already in `index.html`; do not switch to ES modules).
- **Flakes only see git-tracked files:** run `git add -A` before every `nix build` of new/changed files.
- **Build attribute path:** `.#legacyPackages.x86_64-linux.<pkg>`.
- **Headless Firefox:** always use a dedicated `--profile <dir>` and `--new-instance`; NEVER `pkill` Firefox (it kills the user's browser).
- **Commit style:** nixpkgs-style subject (`<component>: <change>`), and end every commit body with `Assisted-by: Claude Code (Claude Fable 5)`. Never add `Co-Authored-By`.

## File Structure

- `overlays/top-level/nixos-reveal-theme/package.nix` — the theme derivation (copies CSS + fonts).
- `overlays/top-level/nixos-reveal-theme/theme.css` — reveal theme (variables + rules + `@font-face`).
- `overlays/top-level/nixos-reveal-theme/highlight.css` — custom highlight.js token theme.
- `overlays/top-level/beholden-to-no-one/package.nix` — modified: add `nixos-reveal-theme` dep, copy it to `theme/`.
- `overlays/top-level/beholden-to-no-one/index.html` — modified: swap the two stylesheet links.

Auto-discovery: a `package.nix` under `overlays/top-level/<name>/` becomes `pkgs.<name>` via `packagesFromDirectoryRecursive`. `theme.css`/`highlight.css` beside it are plain data files, ignored by discovery.

**Testing note (this domain):** there is no unit-test runner; the test cycle is *build the derivation and assert the expected files exist* (Tasks 1-2) and *render with headless Firefox and visually confirm* (Task 3). Steps below use that as the red/green cycle.

______________________________________________________________________

### Task 1: Create the `nixos-reveal-theme` package

**Files:**

- Create: `overlays/top-level/nixos-reveal-theme/theme.css`
- Create: `overlays/top-level/nixos-reveal-theme/highlight.css`
- Create: `overlays/top-level/nixos-reveal-theme/package.nix`

**Interfaces:**

- Consumes (callPackage args): `lib`, `stdenvNoCC`, `lato`, `atkinson-hyperlegible-next`, `atkinson-hyperlegible-mono` (all top-level nixpkgs attrs).

- Produces: package `nixos-reveal-theme` whose `$out` contains `theme.css`, `highlight.css`, and `fonts/` with 8 TTFs. Consumed by Task 2.

- [ ] **Step 1: Write `theme.css`**

```css
/* nixos-reveal-theme — light, NixOS-branded reveal.js theme.
 * Palette: official @nixos/branding (OKLCH). Fonts bundled under fonts/.
 * Rule set modeled on reveal's stock light theme; the rules consume the
 * :root variables, so tuning is mostly editing :root. Values are starting
 * points, tuned live. */

@font-face { font-family:'Lato'; font-style:normal; font-weight:400;
  src:url('fonts/Lato-Regular.ttf') format('truetype'); }
@font-face { font-family:'Lato'; font-style:normal; font-weight:700;
  src:url('fonts/Lato-Bold.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Next'; font-style:normal; font-weight:400;
  src:url('fonts/AtkinsonHyperlegibleNext-Regular.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Next'; font-style:normal; font-weight:700;
  src:url('fonts/AtkinsonHyperlegibleNext-Bold.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Next'; font-style:italic; font-weight:400;
  src:url('fonts/AtkinsonHyperlegibleNext-Italic.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Next'; font-style:italic; font-weight:700;
  src:url('fonts/AtkinsonHyperlegibleNext-BoldItalic.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Mono'; font-style:normal; font-weight:400;
  src:url('fonts/AtkinsonHyperlegibleMono-Regular.ttf') format('truetype'); }
@font-face { font-family:'Atkinson Hyperlegible Mono'; font-style:normal; font-weight:700;
  src:url('fonts/AtkinsonHyperlegibleMono-Bold.ttf') format('truetype'); }

:root{
  --r-background-color: oklch(0.98 0 0);
  --r-main-font: 'Atkinson Hyperlegible Next', sans-serif;
  --r-main-font-size: 42px;
  --r-main-color: oklch(0.15 0 0);
  --r-block-margin: 20px;
  --r-heading-margin: 0 0 20px 0;
  --r-heading-font: 'Lato', sans-serif;
  --r-heading-color: oklch(0.55 0.12 264);
  --r-heading-line-height: 1.2;
  --r-heading-letter-spacing: normal;
  --r-heading-text-transform: none;
  --r-heading-text-shadow: none;
  --r-heading-font-weight: 700;
  --r-heading1-text-shadow: none;
  --r-heading1-size: 2.5em;
  --r-heading2-size: 1.6em;
  --r-heading3-size: 1.3em;
  --r-heading4-size: 1em;
  --r-code-font: 'Atkinson Hyperlegible Mono', monospace;
  --r-link-color: oklch(0.45 0.12 264);
  --r-link-color-dark: oklch(0.40 0.12 264);
  --r-link-color-hover: oklch(0.55 0.11 330);
  --r-selection-background-color: oklch(0.75 0.09 240);
  --r-selection-color: oklch(0.15 0 0);
  --r-overlay-element-bg-color: 0 0 0;
  --r-overlay-element-fg-color: 240 240 240;
}

.reveal-viewport{background:var(--r-background-color)}
.reveal{font-family:var(--r-main-font);font-size:var(--r-main-font-size);color:var(--r-main-color);font-weight:400}
.reveal ::selection{color:var(--r-selection-color);background:var(--r-selection-background-color);text-shadow:none}
.reveal .slides section,.reveal .slides section>section{line-height:1.3;font-weight:inherit}
.reveal h1,.reveal h2,.reveal h3,.reveal h4,.reveal h5,.reveal h6{margin:var(--r-heading-margin);color:var(--r-heading-color);font-family:var(--r-heading-font);font-weight:var(--r-heading-font-weight);line-height:var(--r-heading-line-height);letter-spacing:var(--r-heading-letter-spacing);text-transform:var(--r-heading-text-transform);text-shadow:var(--r-heading-text-shadow);word-wrap:break-word}
.reveal h1{font-size:var(--r-heading1-size)}
.reveal h2{font-size:var(--r-heading2-size)}
.reveal h3{font-size:var(--r-heading3-size)}
.reveal h4{font-size:var(--r-heading4-size)}
.reveal h1{text-shadow:var(--r-heading1-text-shadow)}
.reveal p{margin:var(--r-block-margin) 0;line-height:1.3}
.reveal h1:last-child,.reveal h2:last-child,.reveal h3:last-child,.reveal h4:last-child,.reveal h5:last-child,.reveal h6:last-child{margin-bottom:0}
.reveal img,.reveal video,.reveal iframe{max-width:95%;max-height:95%}
.reveal strong,.reveal b{font-weight:700}
.reveal em{font-style:italic}
.reveal ol,.reveal dl,.reveal ul{text-align:left;margin:0 0 0 1em;display:inline-block}
.reveal ol{list-style-type:decimal}
.reveal ul{list-style-type:disc}
.reveal ul ul{list-style-type:square}
.reveal ul ul ul{list-style-type:circle}
.reveal ul ul,.reveal ul ol,.reveal ol ol,.reveal ol ul{margin-left:40px;display:block}
.reveal dt{font-weight:700}
.reveal dd{margin-left:40px}
.reveal blockquote{width:70%;margin:var(--r-block-margin) auto;background:oklch(0.96 0.01 240);padding:5px;font-style:italic;display:block;position:relative;box-shadow:0 0 2px #0003}
.reveal blockquote p:first-child,.reveal blockquote p:last-child{display:inline-block}
.reveal q{font-style:italic}
.reveal pre{width:90%;margin:var(--r-block-margin) auto;text-align:left;font-size:.55em;font-family:var(--r-code-font);word-wrap:break-word;line-height:1.2em;display:block;position:relative;box-shadow:0 5px 15px #00000026}
.reveal code{font-family:var(--r-code-font);text-transform:none;tab-size:2}
.reveal pre code{word-wrap:normal;max-height:400px;padding:5px;display:block;overflow:auto}
.reveal .code-wrapper{white-space:normal}
.reveal .code-wrapper code{white-space:pre}
.reveal table{border-collapse:collapse;border-spacing:0;margin:auto}
.reveal table th{font-weight:700}
.reveal table th,.reveal table td{text-align:left;border-bottom:1px solid;padding:.2em .5em}
.reveal table tbody tr:last-child th,.reveal table tbody tr:last-child td{border-bottom:none}
.reveal sup{vertical-align:super;font-size:smaller}
.reveal sub{vertical-align:sub;font-size:smaller}
.reveal small{vertical-align:top;font-size:.6em;line-height:1.2em;display:inline-block}
.reveal img{margin:var(--r-block-margin) 0}
.reveal a{color:var(--r-link-color);text-decoration:none;transition:color .15s}
.reveal a:hover{color:var(--r-link-color-hover);text-shadow:none;border:none}
.reveal .progress{color:var(--r-link-color)}
.reveal .controls{color:var(--r-link-color)}
```

- [ ] **Step 2: Write `highlight.css`**

```css
/* nixos-reveal-theme highlight.js theme — light background, NixOS accents.
 * Token colors from @nixos/branding (OKLCH). Starting points, tuned live.
 * reveal.css handles line-number stepping and line dimming; this file only
 * styles tokens, the code block background, and code color. */
.reveal .hljs{
  background: oklch(0.96 0.01 240);
  color: oklch(0.25 0 0);
  border-radius: 4px;
}
.hljs-comment,.hljs-quote{ color: oklch(0.55 0 0); font-style: italic; }
.hljs-keyword,.hljs-selector-tag{ color: oklch(0.55 0.12 264); }
.hljs-number,.hljs-literal{ color: oklch(0.55 0.11 54); }
.hljs-string,.hljs-meta-string{ color: oklch(0.50 0.10 152); }
.hljs-title,.hljs-section,.hljs-name{ color: oklch(0.50 0.11 288); }
.hljs-type,.hljs-built_in{ color: oklch(0.55 0.11 330); }
.hljs-attr,.hljs-attribute,.hljs-variable,.hljs-template-variable{ color: oklch(0.55 0.11 240); }
.hljs-meta{ color: oklch(0.55 0 0); }
.hljs-subst{ color: oklch(0.25 0 0); }
.hljs-emphasis{ font-style: italic; }
.hljs-strong{ font-weight: 700; }
```

- [ ] **Step 3: Write `package.nix`**

```nix
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
```

- [ ] **Step 4: Build and assert the output (the test)**

Run:

```bash
cd ~/dev/djacu/talks && git add -A && \
nix build .#legacyPackages.x86_64-linux.nixos-reveal-theme \
  -o /tmp/nixos-reveal-theme-result && \
ls /tmp/nixos-reveal-theme-result/ && ls /tmp/nixos-reveal-theme-result/fonts/
```

Expected: build succeeds; top level lists `theme.css  highlight.css  fonts`; `fonts/` lists the 8 TTFs (Lato-Regular, Lato-Bold, AtkinsonHyperlegibleNext-{Regular,Bold,Italic,BoldItalic}, AtkinsonHyperlegibleMono-{Regular,Bold}).

- [ ] **Step 5: Format and check**

Run: `nix fmt && nix flake check`
Expected: `all checks passed!`

- [ ] **Step 6: Commit**

```bash
git add overlays/top-level/nixos-reveal-theme
git commit -m "nixos-reveal-theme: init

Reusable light reveal.js theme using the official NixOS OKLCH palette
(@nixos/branding), Lato + Atkinson Hyperlegible + Atkinson Mono fonts bundled
from nixpkgs, and a matching custom highlight.js code theme. Colors are starting
points to be tuned live.

Assisted-by: Claude Code (Claude Fable 5)"
```

______________________________________________________________________

### Task 2: Switch the `beholden-to-no-one` deck onto the theme

**Files:**

- Modify: `overlays/top-level/beholden-to-no-one/package.nix`
- Modify: `overlays/top-level/beholden-to-no-one/index.html`

**Interfaces:**

- Consumes: `nixos-reveal-theme` from Task 1 (its `$out` with `theme.css`, `highlight.css`, `fonts/`).

- Produces: a deck whose `$out/theme/` holds the theme and whose `index.html` links `theme/theme.css` + `theme/highlight.css`.

- [ ] **Step 1: Update `package.nix` to depend on and install the theme**

Replace the entire file with:

```nix
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
    cp ${./index.html} $out/index.html

    runHook postInstall
  '';

  meta = {
    description = "Slides: Beholden to No One: The Nix Override Ladder (Nix Vegas 2026)";
    platforms = lib.platforms.all;
  };

}
```

- [ ] **Step 2: Update `index.html` stylesheet links**

Change the theme link. Replace:

```html
    <link rel="stylesheet" href="dist/theme/black.css" id="theme" />
```

with:

```html
    <link rel="stylesheet" href="theme/theme.css" id="theme" />
```

Change the highlight link. Replace:

```html
    <link rel="stylesheet" href="dist/plugin/highlight/monokai.css" />
```

with:

```html
    <link rel="stylesheet" href="theme/highlight.css" />
```

Leave the `<script>` tags (`dist/reveal.js`, `dist/plugin/notes.js`, `dist/plugin/highlight.js`) unchanged.

- [ ] **Step 3: Build and assert asset resolution (the test)**

Run:

```bash
cd ~/dev/djacu/talks && git add -A && \
nix build .#legacyPackages.x86_64-linux.beholden-to-no-one \
  -o /tmp/talk-result && \
for f in index.html dist/reveal.js theme/theme.css theme/highlight.css \
  theme/fonts/AtkinsonHyperlegibleNext-Regular.ttf theme/fonts/Lato-Bold.ttf; do
  test -e /tmp/talk-result/$f && echo "OK  $f" || echo "MISSING  $f"; done && \
grep -c 'theme/theme.css\|theme/highlight.css' /tmp/talk-result/index.html
```

Expected: all `OK`; the `grep -c` prints `2`.

- [ ] **Step 4: Format and check**

Run: `nix fmt && nix flake check`
Expected: `all checks passed!`

- [ ] **Step 5: Commit**

```bash
git add overlays/top-level/beholden-to-no-one
git commit -m "beholden-to-no-one: use nixos-reveal-theme

Depend on the nixos-reveal-theme package, copy it into the deck's theme/, and
point the deck's stylesheet links at theme/theme.css and theme/highlight.css
instead of reveal's bundled black + monokai themes.

Assisted-by: Claude Code (Claude Fable 5)"
```

______________________________________________________________________

### Task 3: Render and tune colors live

**Files:**

- Modify (iteratively): `overlays/top-level/nixos-reveal-theme/theme.css`
- Modify (iteratively): `overlays/top-level/nixos-reveal-theme/highlight.css`

**Interfaces:**

- Consumes: the built deck from Task 2.

- Produces: final tuned OKLCH values; no interface change.

- [ ] **Step 1: Render the title and code slides**

Run (dedicated profiles; never pkill Firefox):

```bash
cd ~/dev/djacu/talks && git add -A && \
nix build .#legacyPackages.x86_64-linux.beholden-to-no-one -o /tmp/talk-result
SC=/tmp/theme-tune; mkdir -p "$SC"
T=$(realpath /tmp/talk-result)
firefox --headless --new-instance --profile "$SC/p1" --window-size=1600,900 \
  --screenshot "$SC/title.png" "file://$T/index.html" 2>/dev/null
firefox --headless --new-instance --profile "$SC/p2" --window-size=1600,900 \
  --screenshot "$SC/code.png" "file://$T/index.html#/1" 2>/dev/null
ls -l "$SC"/*.png
```

Expected: `title.png` and `code.png` exist.

- [ ] **Step 2: Inspect the screenshots**

Open/read `title.png` and `code.png`. Confirm: near-white background; NixOS-dark-blue heading in Lato; near-black body in Atkinson; on the code slide, a light code block with distinct token colors (blue keywords, green strings, orange numbers) in Atkinson Mono; text is legible (no low-contrast pale-on-white).

- [ ] **Step 3: Adjust and re-render as needed**

For any color that is too light/low-contrast, lower its OKLCH lightness (the `L` in `oklch(L C H)`) in `theme.css` (headings/links) or `highlight.css` (tokens); for too-dark, raise it. Re-run Step 1 after each change (the `git add -A` in that command picks up edits). Repeat until legible and on-brand. Keep chroma/hue as given; tune mainly `L`.

- [ ] **Step 4: Final check**

Run: `nix fmt && nix flake check`
Expected: `all checks passed!`

- [ ] **Step 5: Commit the tuned values**

```bash
git add overlays/top-level/nixos-reveal-theme
git commit -m "nixos-reveal-theme: tune colors for contrast

Adjust OKLCH lightness of headings, links, and code tokens against rendered
screenshots for legibility on a light background.

Assisted-by: Claude Code (Claude Fable 5)"
```

______________________________________________________________________

## Self-Review

**Spec coverage:** light theme (Task 1 `:root` background) ✓; official `@nixos/branding` OKLCH palette (Tasks 1-2, Global Constraints) ✓; custom highlight theme (Task 1 Step 2) ✓; offline fonts bundled (Task 1 Step 3, `@font-face` relative URLs) ✓; reusable package like `reveal-js` (Task 1) ✓; deck integration by swapping two links (Task 2) ✓; live screenshot tuning loop (Task 3) ✓; reveal `--r-*` interface (Task 1 `theme.css`) ✓. Deferred items from the spec (NixOS logo on title, contrast-final values) are intentionally out of scope / handled by Task 3.

**Placeholder scan:** no TBD/TODO; all CSS, Nix, and commands are complete and literal.

**Type/name consistency:** package attr `nixos-reveal-theme` used consistently as dir name, callPackage arg in Task 2, and build target; font filenames match the verified nixpkgs paths; `theme/theme.css` and `theme/highlight.css` paths consistent between `package.nix` copy and `index.html` links.
