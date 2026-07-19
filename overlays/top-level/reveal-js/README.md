# reveal-js

The [reveal.js](https://revealjs.com) HTML presentation framework, packaged from
its prebuilt `dist/` directory. Talk decks in this repo depend on this package
and copy `dist/` next to their `index.html`.

## Why dist/-only

reveal.js commits a prebuilt `dist/` to its repository, so packaging needs no
npm or bundler step. `dist/` is the complete runtime artifact and is all a deck
ever references. The top-level `plugin/` directory in the reveal.js repo is
Vite + TypeScript *build source* (`index.ts`, `plugin.js`, `vite.config.ts`); it
is compiled into `dist/plugin/*.js` and is not needed at runtime, so we do not
install it. Keeping it would not help future plugin needs: built-in plugins are
already in `dist/`, and third-party plugins come from their own repos (see
below).

## Built-in plugins (all shipped in dist/)

`dist/plugin/` contains all six built-in plugins as UMD (`.js`), ESM (`.mjs`),
and type (`.d.ts`) builds:

| Plugin | Purpose |
| --------- | -------------------------------------------------------- |
| highlight | Code syntax highlighting (highlight.js) |
| markdown | Author slides in Markdown |
| math | KaTeX / MathJax formulas |
| notes | Speaker view (self-contained; HTML inlined into the JS) |
| search | Ctrl-F across slides |
| zoom | Alt-click to zoom into a region |

## Use the classic script includes, not ES modules

Include reveal via classic `<script src="dist/reveal.js">` tags and the plugin
globals (`RevealHighlight`, `RevealNotes`, ...), exactly as reveal's own demo
`index.html` does:

```html
<script src="dist/reveal.js"></script>
<script src="dist/plugin/highlight.js"></script>
<script>
  Reveal.initialize({ plugins: [RevealHighlight] });
</script>
```

Do **not** use the ES-module form (`<script type="module">` with `import`). ES
module imports are CORS-gated, and a deck opened from a bare `file://` path has a
null origin, so those imports are blocked by the browser. Classic scripts have
no such restriction and load fine from a file. This lets a built deck open by
double-clicking `index.html` with no web server, including on a borrowed
conference laptop. This is browser behaviour and unrelated to Nix.

## Offline status

The deck is fully self-contained and offline, with one exception:

- **math plugin**: defaults to loading KaTeX/MathJax from `cdn.jsdelivr.net`. It
  only fetches when the math plugin is enabled. To use math offline, point its
  config at a locally packaged KaTeX/MathJax.
- **highlight themes**: only `monokai.css` and `zenburn.css` are bundled under
  `dist/plugin/highlight/`. Other highlight.js themes must be added if wanted.
- Theme fonts are inlined as base64 data URIs, so themes need no network.
- Core `reveal.js` / `reveal.css` have no runtime remote references.

## Code line highlighting and stepping (built-in)

The highlight plugin steps through line ranges with no third-party plugin:

```html
<pre><code class="language-nix" data-trim data-line-numbers="1|2-3|4">
...
</code></pre>
```

`|` separates steps; `data-ln-start-from="N"` offsets excerpt line numbering.

## Third-party plugins

The
[wiki](https://github.com/hakimel/reveal.js/wiki/Plugins,-Tools-and-Hardware)
lists a large third-party ecosystem. Those plugins live in their own repos
(standalone JS or npm packages), not in reveal.js's `plugin/` directory. To use
one here, package it as its own top-level derivation (like this one) via
`fetchFromGitHub`, have the talk depend on it, copy its JS into the deck, and
register its global in the `plugins:` array.
