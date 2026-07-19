# Design: `nixos-reveal-theme`

A reusable, light-background reveal.js theme for Nix Vegas talks, using the
official NixOS brand palette, plus a matching custom highlight.js code theme.

## Goals

- A **light** theme, built for projector legibility (dark backgrounds have been
  a problem in the past).
- Uses the **official NixOS brand colors** from `@nixos/branding`.
- A **custom highlight.js theme** so code blocks are also light and on-brand
  (not one of reveal's bundled dark themes).
- Fully **offline**: fonts and CSS bundled, no network at display time.
- **Reusable** across every future talk in this repo, packaged like `reveal-js`.

## Non-goals

- No dark variant (not needed).
- No custom logo/artwork work in this pass (an optional NixOS logo on the title
  slide is deferred; see Open items).

## Palette (source: `@nixos/branding` v0.1.0, `colors/tailwind.js`)

Colors are OKLCH, which all current browsers support natively, so the official
values go into the CSS unchanged. Headline brand colors (cross-checked against
the branding guide hexes):

- NixOS dark blue: `oklch(0.55 0.12 264)` (≈ `#4d6fb7`)
- NixOS light blue: `oklch(0.75 0.09 240)` (≈ `#77b6e1`)
- Neutrals: `primary-black` `oklch(0 0 0)` (+ lightness scale 15–95),
  `primary-white` `oklch(1 0 0)`
- Named accents (hue): chinese-magenta 330, indian-gold 90, italian-violet 288,
  norwegian-pink 16, persian-orange 54, zambian-green 152

### Role assignment (reveal theme)

| Role | Value |
| --- | --- |
| Background (`--r-background-color`) | near-white `oklch(0.98 0 0)` |
| Body text (`--r-main-color`) | near-black `oklch(0.15 0 0)` |
| Headings (`--r-heading-color`) | NixOS dark blue `oklch(0.55 0.12 264)` |
| Links (`--r-link-color`) | NixOS dark blue; hover uses the emphasis accent |
| Rules / borders / progress | NixOS light blue `oklch(0.75 0.09 240)` |
| Emphasis accent | `accent-chinese-magenta`, used sparingly |
| Selection | light-blue background, near-black text |

Contrast note: link/accent lightness may be darkened (toward L≈0.45) to hit
WCAG-AA at body-text size. Exact lightness values are tuned live (see
Verification); the mapping above is the starting point, not final.

## Typography (source: nixpkgs, all OFL)

- Headings: **Lato** (`lato`), weight 700.
- Body: **Atkinson Hyperlegible** (`atkinson-hyperlegible-next`), designed for
  legibility.
- Code: **Atkinson Hyperlegible Mono** (`atkinson-hyperlegible-mono`), so the
  code font also serves legibility and matches the family.

Font files are copied from the nixpkgs font packages into the theme output and
referenced by bundled `@font-face` rules (relative paths), so the deck needs no
network. Reveal variables set: `--r-main-font` (Atkinson), `--r-heading-font`
(Lato), `--r-code-font` (Atkinson Mono).

## Custom highlight theme (`highlight.css`)

Maps highlight.js token classes to NixOS accents on a light code background.
reveal's own CSS handles line-number stepping and line dimming; this file only
provides token colors, the code block background, and the code font.

| Token class | Color |
| --- | --- |
| `.hljs` background | light blue tint `oklch(0.96 0.01 240)` |
| base text | near-black `oklch(0.25 0 0)` |
| `.hljs-comment`, `.hljs-quote` | muted gray `oklch(0.55 0 0)`, italic |
| `.hljs-keyword`, `.hljs-selector-tag` | NixOS dark blue `oklch(0.55 0.12 264)` |
| `.hljs-string` | zambian-green `oklch(0.50 0.10 152)` |
| `.hljs-number`, `.hljs-literal` | persian-orange `oklch(0.55 0.11 54)` |
| `.hljs-title`, `.hljs-section` | italian-violet `oklch(0.50 0.11 288)` |
| `.hljs-type`, `.hljs-built_in` | chinese-magenta `oklch(0.55 0.11 330)` |
| `.hljs-attr`, `.hljs-variable` | argentinian-blue `oklch(0.55 0.11 240)` |

Priority is the Nix grammar's tokens (keyword, string, comment, number,
built_in, attr, meta, subst). Exact lightness tuned live for contrast on the
light code background.

## Architecture

### `nixos-reveal-theme` package

New top-level package at `overlays/top-level/nixos-reveal-theme/package.nix`,
auto-discovered by the overlay, built with `stdenvNoCC`.

- **Inputs (callPackage args):** `lato`, `atkinson-hyperlegible-next`,
  `atkinson-hyperlegible-mono`, `lib`, `stdenvNoCC`.
- **Output contract (`$out/`):**
  - `theme.css` — reveal theme: `:root` `--r-*` variables, `@font-face` rules
    referencing `fonts/`, and any extra selectors.
  - `highlight.css` — the custom highlight.js theme.
  - `fonts/` — the needed weights copied from the nixpkgs font packages (Lato
    400/700, Atkinson regular/bold + italics, Atkinson Mono regular).
- The CSS source files live in the package directory and are assembled/copied in
  `installPhase`; font files are copied from `${lato}`, `${atkinson-*}` store
  paths. `@font-face` uses relative `fonts/...` URLs so the set is portable when
  copied into a deck.

### Talk consumption (`beholden-to-no-one`)

- `package.nix` gains a `nixos-reveal-theme` dependency; `installPhase` copies
  `${nixos-reveal-theme}` into `$out/theme/` (so `$out/theme/theme.css`,
  `$out/theme/highlight.css`, `$out/theme/fonts/`).
- `index.html`:
  - replace `<link ... href="dist/theme/black.css">` with
    `<link ... href="theme/theme.css">`
  - replace `<link ... href="dist/plugin/highlight/monokai.css">` with
    `<link ... href="theme/highlight.css">`
  - `dist/` (reveal runtime + plugins) is still copied from `reveal-js`
    unchanged.

The `@font-face` relative paths resolve to `theme/fonts/` inside the deck.

## Verification

- Build `nixos-reveal-theme` and `beholden-to-no-one`.
- Render with headless Firefox using a dedicated `--profile` and
  `--new-instance` (never `pkill` the user's Firefox), screenshotting the title
  slide and the code slide, then read the images.
- **Live tuning loop:** adjust OKLCH lightness/chroma for headings, links,
  accents, and code tokens until contrast and legibility look right in the
  rendered screenshots. The color maps above are starting points; the user tunes
  live once visible.
- Confirm: light background, dark-blue headings, legible body, light code block
  with NixOS-accent tokens in Atkinson Mono, fonts loading from the bundle (no
  network).

## Open / deferred items

- Exact contrast-tuned OKLCH values (finalized during the live tuning loop).
- Optional NixOS logo on the title slide (official SVGs ship in
  `@nixos/branding`); deferred to a later pass.
- Confirm exact font-file paths/weights inside the nixpkgs font packages during
  implementation.
