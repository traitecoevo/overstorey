---
name: new-reproduction
description: >-
  Scaffold a new Reproduction post for the overstorey Quarto site — one that
  re-runs a published figure from a plant paper as a living regression check.
  Use when the user wants to "add/create a reproduction", "reproduce Figure N
  of <paper>", "re-run a paper figure", or set up the three-way published-vs-
  paper-code-vs-current-plant comparison. Handles the template copy, version
  pinning, paper-code submodule, freeze commit, and pre-flighting the
  reproduction lint so the PR doesn't fail CI. NOT for ordinary blog/notebook
  posts — for those just copy a neighbouring post directory.
---

# New reproduction post

A **reproduction post** re-runs a key figure from one of the `plant` papers
and compares it three ways:

1. **Published** — the original panel (PNG or DOI link).
2. **Paper code, today** — the paper's *own* figure script (pinned commit),
   re-run against current deps. (1) vs (2) flags **paper-code bit-rot**.
3. **Current `plant`** — the same result through today's model API. (2) vs (3)
   is the **model-drift** signal.

This is the most procedural post type in the repo and the only one gated by a
merge-blocking lint (`R/check_reproductions.R`). Get the steps below right and
the PR passes CI on the first try.

## Cardinal rule — never invent paper specifics

Every parameter value, DOI, author list, figure number, and `code-ref` is
`TODO` in the template **on purpose**: it can't be verified from the codebase.
The repo owner supplies these. Either:

- get the verified value from the user and fill it in, **or**
- leave the `TODO` in place **and keep the post under `posts/_drafts/`** (the
  lint exempts anything under `posts/_*`).

Never guess a DOI, year, figure number, or commit. A guessed value that looks
filled-in is worse than an honest `TODO` in a draft.

## Before you start — collect verified inputs

Ask the user for anything you don't have. You need:

- **Slug + date** → directory `posts/YYYY-MM-DD-<slug>/`.
- **Paper metadata**: authors, year, title, journal, DOI, the figure being
  reproduced (e.g. "Figure 3b").
- **Pin target** (see below): a released `plant` version, or a develop
  branch + commit SHA.
- **Paper code**: is there an original figure-code repo? Its GitHub path, the
  publication tag/SHA, and the path to the figure script within it.
- **Published panel**: may we redistribute the PNG, or must we link the DOI?

If the user can't supply the verified specifics yet, scaffold into
`posts/_drafts/` and stop — don't publish a half-filled reproduction.

## Pinning decision

The post must pin to the exact `plant` state it ran against. Pick one:

- **Released / master** → `plant-version: "2.1.0"` (delete the `plant-ref`/
  `plant-sha` lines).
- **Develop / unreleased** → `plant-ref: "develop"` + `plant-sha: "<sha>"`
  (full or short — the badge truncates to 7). Delete the `plant-version` line.

The lint requires `plant-version` **OR** (`plant-ref` **and** `plant-sha`).

## Paper-code provenance decision

Set the `paper.code-*` fields and wire up `paper-code/<slug>/`. Two options
(see `paper-code/README.md`):

- **Option A — git submodule** (preferred when the repo is clean):
  ```bash
  git submodule add https://github.com/traitecoevo/<paper-repo> paper-code/<slug>
  cd paper-code/<slug> && git checkout <publication-tag-or-sha> && cd -
  git add .gitmodules paper-code/<slug>
  ```
  CI checks these out with `submodules: recursive`.
- **Option B — vendored snapshot** (repo heavy/unfetchable): copy just the
  figure script + inputs into `paper-code/<slug>/`, still record the upstream
  `code-ref` for provenance.
- **No paper code**: leave `code-repo: ""`. The `paper_code_badge()` renders
  empty and the post becomes a hand-transcription reproduction (two-way:
  published vs current `plant`). Drop the "paper code, today" chunk.

Record the same ref in `paper.code-ref` so the badge matches the checked-out
tree.

## Steps

1. **Copy the template** (do not edit the template in place):
   ```bash
   cp -R posts/_reproduction-template posts/YYYY-MM-DD-<slug>
   ```
   For an unfinished post with unverified specifics, copy into
   `posts/_drafts/YYYY-MM-DD-<slug>` instead.

2. **Fill the front matter**: `title`, `description`, `date`, the pin (one of
   the two forms above), `categories: [reproduction, <topic>]` — keep
   `reproduction` — and the whole `paper:` block. Set `fidelity:` only once you
   know the verdict (`matches` | `differs` | `approximate`); it starts
   `pending`.

3. **Keep the setup chunk and badge/citation lines** the template ships with —
   they drive the rendered badges and citation box:
   ```r
   source(here::here("R/version-badge.R"))
   source(here::here("R/reproduction.R"))
   ```
   ```
   `r plant_version_badge()` `r repro_fidelity_badge()` `r paper_code_badge()`
   `r paper_citation()`
   ```

4. **Fill the body**: "What the original shows", the verbatim paper parameters
   (cite the table/section for each), the "paper code, today" chunk (sources
   `<code-entrypoint>` from `paper-code/<slug>/`), the "current `plant`" chunk,
   the side-by-side, and a plain **Verdict**. Set chunks `#| eval: true` once
   the code path actually runs; leave `eval: false` only while it can't.

5. **Add the published panel** at `assets/papers/<slug>.png`, or if licensing
   forbids redistribution, link it at the DOI and describe it.

6. **Render and verify the figures** — actually look at them, don't assume:
   ```bash
   quarto render posts/YYYY-MM-DD-<slug>/index.qmd
   ```
   Open the generated PNGs under `_freeze/.../figure-html/` and confirm they
   show the expected result before committing.

7. **Commit `_freeze/` *with* the content** (repo invariant — always together):
   ```bash
   git add posts/YYYY-MM-DD-<slug>/ _freeze/posts/YYYY-MM-DD-<slug>/ \
           .gitmodules paper-code/<slug>   # last two only if you added a submodule
   ```
   If you bumped packages, also `renv::snapshot()` and stage `renv.lock`.

8. **Pre-flight the lint before opening a PR to master**:
   ```bash
   Rscript R/check_reproductions.R
   ```
   It must print "All reproduction posts are complete and pinned." See the gate
   checklist below.

## Lint gate checklist (`R/check_reproductions.R`)

A **published** reproduction post (has the `reproduction` category, **not**
under `posts/_*`) must satisfy all of these or CI blocks the merge:

- [ ] **Pinned** — `plant-version`, or both `plant-ref` and `plant-sha`.
- [ ] **Fidelity decided** — `paper.fidelity` is `matches`, `differs`, or
      `approximate`, never `pending`.
- [ ] **No `TODO`** — the word `TODO` appears nowhere in the `paper:` block or
      the pin fields.

Drafts under `posts/_drafts/` (and the `posts/_reproduction-template/`) are
**exempt** — that's where an in-progress post belongs until its specifics are
verified. Moving a draft out of `_drafts/` is the act of publishing it; only do
that once all three gates pass.

## Freeze discipline (don't break it)

- `freeze: auto` means a post re-executes only when its own source changes.
  `_freeze/` is the committed source of truth for what each page computed.
- **Never** add a global `quarto render --cache-refresh` to CI — it would
  silently rewrite published develop-pinned figures and undo the whole
  reproducibility design.
- The only job allowed to invalidate a freeze is the manual, targeted
  `refresh.yml`. To re-run a single post locally after a `plant` bump:
  `quarto render --cache-refresh` for that file only, then eyeball figure diffs
  and commit the new `_freeze/`.

## When NOT to use this skill

For an ordinary notebook/blog post (a benchmark, a case study, a prototype),
there's no paper to reproduce and no lint to satisfy — just copy a neighbouring
`posts/<date>-<slug>/` directory, adjust the front matter, render, and commit
the freeze. A pure `deSolve`/prototype post that doesn't touch the `plant` API
follows the water-bucket pattern (no `plant` pin + a callout note).
