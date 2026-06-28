# CLAUDE.md — overstorey

**Overstorey** (repo: `traitecoevo/overstorey`) is the Quarto documentation
site for [`plant`](https://github.com/traitecoevo/plant),
an R package for size-structured, trait-based forest modelling. This file is
persistent context for Claude Code sessions. Read it, plus `develop.qmd` and
`_quarto.yml`, before changing anything.

## Status

The scaffold exists but **nothing has been rendered or verified** — it was
built in an environment with no R or Quarto. The first job in any fresh
session is to make `quarto preview` work and fix what breaks. Do not assume
SCSS, the animated hero, or the inline badge helpers render correctly until
proven.

## What the site is

A Quarto **website** (not pkgdown — that stays separate for API reference),
with four parts plus a maintainers page:

- **Guides** (`guides/`) — task walkthroughs, migrated from vignettes.
- **Theory** (`theory/`) — consolidated maths.
- **Adaptively** (`posts/`, `posts/index.qmd`) — the version-pinned
  notebook/blog. Display name only; the route stays `posts/`. Not to be
  confused with the Theory page **Adaptive dynamics**
  (`theory/adaptive-dynamics.qmd`).
- **Reproductions** (`posts/reproductions.qmd`) — re-running key figures from
  our papers as living regression checks.
- **Pipeline** (`develop.qmd`) — documents the CI/reproducibility design.

API reference stays on the package's pkgdown site. `pkgdown-crosslink.yml`
holds keys to merge into `plant`'s own `_pkgdown.yml` so the two sites
cross-link and share the canopy palette/fonts.

## Architecture — understand before editing

**Freeze is the spine.** `execute: freeze: auto` means a `.qmd` re-executes
only when its own source changes. `_freeze/` is committed and is the source
of truth for what each page computed. **Always commit `_freeze/` and
`renv.lock` together with any content change.**

**Posts pin to a `plant` state** in front matter:
- master / released: `plant-version: "2.1.0"`
- develop / unreleased: `plant-ref: "develop"` + `plant-sha: "<sha>"`

Helpers in `R/version-badge.R` and `R/reproduction.R` render badges, the
citation box, and the fidelity verdict from this front matter.

**Reproduction posts** can run the original paper's own figure code
(submodules under `paper-code/<slug>/`, pinned via `paper.code-ref`) for a
three-way comparison: published PNG vs paper-code-re-run-today vs current
`plant`. (1) vs (2) flags paper-code bit-rot; (2) vs (3) is the model-drift
signal. See `paper-code/README.md`.

## CI workflows

- `publish.yml` — plain `quarto render` on push to master, honours freezes, deploys.
- `pr-checks.yml` — freeze-consistency check + reproduction lint (on PRs to master).
- `refresh.yml` — manual `workflow_dispatch`; the **only** job allowed to
  invalidate freezes. Renders targeted posts against a chosen `plant` ref to
  an artifact for review, not to production.
- `drift-watch.yml` — weekly; re-runs reproductions against `plant` master
  HEAD and reports which figures moved. Commits nothing.

**Never introduce a global `quarto render --cache-refresh` in CI.** It would
silently rewrite published develop-pinned figures and undo the whole
reproducibility design. Full rationale in `develop.qmd`.

## Branch hygiene (master / develop)

Develop-pinned posts are tied to a moving commit. Routine CI must never
force-refresh them — only the manual, targeted `refresh.yml` may, and
`drift-watch.yml` runs against master and commits nothing.

## Tasks, in order

1. Env setup: `renv::init()`, install `plant` + helper deps (`htmltools`,
   `digest`, `here`), generate `renv.lock`.
2. `quarto preview`, fix render errors. Watch: `assets/plant.scss`, the
   animated canopy hero in `index.qmd`, and whether inline `` `r badge()` ``
   calls render. The freeze-consistency step uses `--no-execute-daemon`,
   which varies by Quarto version — verify it behaves as `develop.qmd`
   claims and adjust if not.
3. Verify `R/check_reproductions.R` and `R/select_targets.R`
   against real post front matter.
4. Migrate the heaviest existing `.Rmd` vignettes into the guide/theory
   stubs (knitr chunk engine is compatible; let freeze cache slow runs).

## Constraints

- **Don't invent paper-specific values.** Every paper parameter, DOI, figure
  number, and paper-code ref in the templates is deliberately `TODO` because
  it can't be verified. The repo owner supplies these. Leave TODOs in place
  and flag where they're needed; never guess.
- The unfinished FF16 reproduction example lives in `posts/_drafts/` on
  purpose so the lint doesn't gate it. Keep incomplete posts there.
- The reproduction lint blocks merging any reproduction post with
  `fidelity: pending`, a `TODO` in its `paper:` block, or no version/commit pin.

## Local loop

```bash
quarto preview          # live edit
quarto render           # full build, updates _freeze/
git add _freeze/ && git commit   # ALWAYS commit freeze with content
```

When bumping packages:
```r
renv::snapshot()
```
```bash
quarto render --cache-refresh    # LOCALLY only, then eyeball figure diffs
git add renv.lock _freeze/ && git commit
```

## Issue & project-board conventions

Development across `plant`, `plant.assembly`, and `overstorey` is tracked on a
shared [project board](https://github.com/orgs/traitecoevo/projects/5). New issues
are auto-added to the board with status **Backlog** by a workflow, so you do not
need to set status manually.

When opening an issue (including whenever the user asks you to create one), always:

- **Set exactly one type label.** Only three labels exist in these repos — do not
  invent new ones:
  - `bug` — an existing feature not functioning as intended
  - `task` — a discrete task needed for a feature (the default — most docs work)
  - `epic` — a new feature or capability, usually an umbrella over several tasks
- **Prefix the title with a theme tag** in square brackets so the board sorts
  cleanly. Most issues in this repo are `[documentation]`; reuse another existing
  theme where it fits, or fall back to `[other]`:

  | Tag | Scope |
  |---|---|
  | `[documentation]` | Documenting model capabilities (guides, theory, reproductions) |
  | `[TF24 hydraulics]` | Hydraulics component of the TF24 strategy |
  | `[TF24 allometry]` | Flexible allometry for the TF24 model |
  | `[TF24 nsc]` | Non-structural carbohydrate storage in TF24 |
  | `[acclimation]` | Acclimation of leaf and other traits |
  | `[simplify interface]` | Consistent interface to the plant & plant.assembly models |
  | `[evol assembly]` | Evolutionary assembly linking plant to plant.assembly |
  | `[Env drivers]` | Driving the model with environmental drivers |
  | `[speed]` | Performance — making the model run faster |
  | `[patch variations]` | Multiple patch setups (multi-patch, stochastic metapopulation, continuous patch) |
  | `[forecasting]` | Enabling forecasting with the plant model |
  | `[other]` | Anything not covered above |

Create issues with `gh issue create -R traitecoevo/overstorey
--title "[documentation] …" --label task` (swap in `bug`/`epic` as appropriate).

## Cross-package context

This repo is part of the **plant family** in the `traitecoevo` org (the narrative documentation site for plant). For
cross-package orientation — how the family fits together, dependency direction,
source-of-truth rules, and the shared label/board conventions — see
**[`plant-meta`](https://github.com/traitecoevo/plant-meta)** (start with its
`AGENTS.md`). Don't restate family-wide concerns here; link to plant-meta and
keep this file about `overstorey`-local matters.
