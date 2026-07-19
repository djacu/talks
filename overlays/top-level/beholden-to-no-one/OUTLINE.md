# Beholden to No One: The Nix Override Ladder

Nix Vegas 2026. Target ~18 min, flex 15-20. Slides marked `[cut-first]` are the
first dropped to reach the low end.

**Thesis:** with Nix you are not beholden to governments, corporations, or
maintainers. The talk walks those three antagonists in turn, then an adversarial
climax, then the ladder that ties it together.

**Structure device:** DuckStation bookends the talk. It is teased in the cold
open (a program flatly refusing to build for you) and resolved in the climax
(the license binds the distro, not you).

All facts below were verified against primary sources during prep; keep the
links in the speaker notes, not on the slides.

______________________________________________________________________

## Open (~2 min)

1. **Cold open: DuckStation refuses you.** [bookend teaser]
   Show `CMakeModules/DuckStationBuildSummary.cmake` erroring out with
   `message(FATAL_ERROR "Unsupported environment.")` because you are on NixOS,
   and the comment above it: "Refuse to build in hostile package environments...
   This is why we can't have nice things." Do not explain yet. Let it hang.

1. **Title:** Beholden to No One / The Nix Override Ladder / Nix Vegas 2026.

1. **Thesis.** Software makes decisions for you: forced updates, telemetry,
   deprecated install methods, licenses that flip, upstreams that decide your OS
   is not real. Comply or quit, unless you have the source. Preview: we climb a
   ladder from "change a setting" to "own the supply chain."

## Mechanics (~2-3 min)

4. **The priority ladder.** `lib.mkOverride` numbers, and the trap that lower
   wins: option-default 1500, `mkDefault` 1000, plain assignment 100, `mkForce`
   50\. The module system has a numeric answer to who wins an argument, and the
   user holds the strong cards.

1. **One real module (nginx).** Purely to show the mechanism, no nginx-specific
   lesson. `ProtectSystem = "strict"` (plain, 100) vs `ProtectHome = mkDefault true` (1000). You override `ProtectHome` silently with a normal assignment;
   overriding `ProtectSystem` conflicts and needs `mkForce`. Use line-stepping.

1. **Firefox policies.** `programs.firefox.policies` repurposes enterprise
   browser-management tooling. Firefox says "your browser is managed by your
   organisation," and the NixOS docs deadpan: "unless of course they also
   control your NixOS configuration." (laugh line)

## Act I: Maintainers (~4 min)

7. **glow PR 886.** The word-wrap fix you need, unmerged for months
   (charmbracelet/glow#886, open since Feb 2026).

1. **Apply it yourself.** `overrideAttrs` + `fetchpatch` the unmerged PR. Code,
   line-stepping, shorten the URL so it does not clip. This is "overrule the
   package."

1. `[cut-first]` **Kernel, same lever at two altitudes.** `boot.kernelPatches`
   (one machine, a module option, list-merged, conditional) vs
   `kernelPackagesExtensions` (every kernel in the package set, an overlay).
   Same `.extend`, different rung of the ladder.

1. **colors.js / faker.js sabotage (Jan 2022).** A maintainer intentionally
   shipped an infinite loop and broke thousands of apps overnight. Pinned
   version + hash means a hostile release cannot reach you silently.

1. **Home Assistant declares you unsupported.** Not a corporation: owned by the
   Open Home Foundation (Swiss non-profit) since April 2024, funded by partner
   Nabu Casa. A maintainer/governance decision: deprecate every install method
   but its own, and warn that non-venv/non-Docker installs "will not work after
   the release of Home Assistant 2026.11" (core#168164).

1. **`nixos-was-never-supported.patch`.** The whole nixpkgs reply is one line:
   `deprecated_method = False` (plus `pythonpath-is-a-venv.patch`). Title
   callback. (payoff of the act)

## Act II: Corporations (~3 min)

13. **VS Code.** Microsoft's proprietary build phones home to auto-update.
    nixpkgs, in a step commented "disable update checks," runs
    `jq 'del(.updateUrl, .backupUpdateUrl)' resources/app/product.json`. Even
    Microsoft's binary bends. VSCodium is the fully-free rebuild.

01. **Terraform goes BSL (Aug 2023).** HashiCorp relicenses overnight. nixpkgs
    marks terraform unfree (#259101) and packages OpenTofu the same day
    (#256307, both 2023-10-06).

## Act III: Governments & the supply chain (~2-3 min)

15. **youtube-dl DMCA (Oct 2020).** RIAA takedown removed the GitHub repo. Nix
    users kept installing throughout, because sources are content-addressed and
    served from cache.nixos.org (nixpkgs#101496).

01. **xz backdoor (CVE-2024-3094).** nixpkgs briefly carried 5.6.1, but the
    payload targeted deb/rpm and checked for `/usr/bin/sshd`, a path NixOS does
    not have (sshd lives in the store). Reverted the same day the CVE dropped
    (#300028).

## Act IV: The adversarial climax (~3 min) [DuckStation payoff]

17. **DuckStation, revisited.** It detects NixOS three ways: `ID=nixos` in
    `/etc/os-release`, the `/etc/NIXOS` marker, and `NIX_*` sandbox env vars.
    Then `FATAL_ERROR`.

01. **The license fights the distro.** CC-BY-NC-ND forbids distributing modified
    build scripts, so nixpkgs cannot ship a workaround. The package was removed
    (`aliases.nix`: `throw "...has been removed following upstream request"`).

01. **But it is still yours.** A private one-line `postPatch` on your own machine
    is legal; applying a patch for yourself is not distribution. The license
    binds the distro, not the user. Resolves the cold open. Even the most hostile
    upstream cannot take the source out of open source.

## Close (~1-2 min)

20. **The ladder.** Seven rungs, revealed as fragments: configure, overrule the
    module, overrule the package, overrule the ecosystem (overlays), overrule
    the distro (`applyPatches` on nixpkgs itself), overrule time (pin any commit,
    roll back anything), own the supply chain (caches, build from source).

01. **Close.** Escape your fate. You have the source.

______________________________________________________________________

## Timing knobs

- ~18 min as written (21 slides).
- To ~17: drop slide 9 (kernel).
- To ~15: also compress 13+14 into one "corporations" slide and 15+16 into one
  "supply chain" slide.

## Bench (verified, not in the current cut)

- **Audacity freeze:** nixpkgs commit ab2a731, "nixpkgs-update: no auto update.
  Humans too!" Available if the maintainers act needs another beat.
- **applyPatches on nixpkgs itself:** the mechanism behind ladder rung 5; can be
  its own slide if the ladder needs more weight.
