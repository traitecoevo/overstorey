# Staged: computational assembly vignettes

These three worked-example vignettes are held back from the live site (this
`_staging/` directory is a leading-underscore path Quarto does not render). The
rest of the adaptive-dynamics section — the model write-ups (DD99/GK98/GM99/JJ12),
the section index, and the main `assembly.qmd` — is live under
`theory/adaptive-dynamics/`.

- `assembly_fitmax.qmd` — max-fitness assembly (1- and 2-trait)
- `assembly_stochastic.qmd` — stochastic assembly
- `solving_attractors.qmd` — solving for attractors

They are not yet render-ready for the site (in addition to the now-fixed
`devtools::load_all()` calls):

- **Dev-machine caching.** They `saveRDS()`/`readRDS()` to a local `output/`
  directory — including reading files that do not exist in the repo (e.g.
  `output/fitmax-lma-old1.rds`, a comparison against a previous run). On a clean
  checkout these error. The caching needs to be removed or made
  self-contained before the pages can freeze.
- **A code bug** in `assembly_stochastic.qmd` (a glue/parse error around the
  filename handling) still needs fixing.
- **Cost.** The stochastic-assembly and attractor runs are heavy (parallel);
  decide how they should be frozen for the site.

Once cleaned up: `git mv` each back to `theory/adaptive-dynamics/`, add it to the
"Adaptive dynamics" section in `_quarto.yml`, `quarto render`, and commit the
`_freeze/`.
