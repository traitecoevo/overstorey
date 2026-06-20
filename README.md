# Overstorey

Quarto documentation site for [`plant`](https://github.com/traitecoevo/plant):
user guides, theory, and a version-pinned notebook. The API reference stays
on the package's pkgdown site; this repo is the narrative layer.

## Why this exists
The vignette set had outgrown its format. This splits docs into:
- **Guides** — task-oriented walkthroughs (migrated from vignettes)
- **Theory** — the maths, consolidated from papers
- **Adaptively** (the notebook) — dated posts, each pinned to the `plant` version it was built against
- **Reference** — unchanged, links out to pkgdown

## Reproducibility model
- `execute: freeze: auto` — a `.qmd` re-runs only when it changes. Commit `_freeze/`.
- `renv.lock` pins packages project-wide. CI restores it before rendering.
- Each notebook post declares its `plant` state in front matter:
  - **master / released:** `plant-version: "2.1.0"` → badge `plant 2.1.0`
  - **develop / unreleased:** `plant-ref: "develop"` + `plant-sha: "a1b2c3d…"`
    → badge `● plant @develop a1b2c3d` (dashed, bark-toned, so it reads as a
    moving target pinned to a commit)
- Expensive posts can pin their own environment with a post-local
  `renv.lock.dev` (see `posts/2026-06-10-hydraulics-benchmark/`).
- Badges + footers are rendered from `R/version-badge.R`.

## Cross-linking with pkgdown
The package's API reference stays on its pkgdown site. `pkgdown-crosslink.yml`
holds the keys to merge into `plant`'s own `_pkgdown.yml` so the two sites
point at each other and share the canopy palette/fonts. This site's navbar
"Reference" link already targets the pkgdown reference index.

## Reproducing an old develop post
1. `git -C plant checkout <plant-sha>` (from the post's front matter)
2. `renv::restore(lockfile = "posts/<slug>/renv.lock.dev")`
3. delete that post's entry under `_freeze/`, then `quarto render`

## Local build
```bash
quarto preview          # live reload
quarto render           # full build to _site/
```

## First-time setup
```r
install.packages("renv")
renv::init()            # snapshot current env -> renv.lock
renv::snapshot()        # after adding packages
```
Then commit `renv.lock`. For the badge helper: `install.packages(c("htmltools","digest","here"))`.
