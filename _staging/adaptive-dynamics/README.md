# Staged: full-plant assembly vignettes

These three worked-example vignettes are held back from the live site (this
`_staging/` directory is a leading-underscore path Quarto does not render). The
rest of the adaptive-dynamics section — the toy-model write-ups
(DD99/GK98/GM99/JJ12), the section index, and the main `assembly.qmd` — is live
under `theory/adaptive-dynamics/`.

- `assembly_fitmax.qmd` — max-fitness assembly (1- and 2-trait)
- `assembly_stochastic.qmd` — stochastic assembly
- `solving_attractors.qmd` — selection gradients and solving for attractors

## Primary blocker: the full-plant assembly path errors

Unlike `assembly.qmd` (which uses the fast **toy models** — `harness_dd99` etc.),
these three drive the **full `plant` SCM** assembly via
`plant_default_assembly_pars()`. Against current plant `develop`, even the basic
workflow

```r
community_start(..., model_support = list(p = plant_default_assembly_pars(), ...)) |>
  community_add(trait_matrix(x, "lma"), birth_rate = 200) |>
  community_demography() |>
  community_selection_gradient()
```

fails with:

```
Error: Run a resident first to generate a competitve landscape
```

thrown in plant C++ (`inst/include/plant/patch.h:244`). plant requires a
resident's SCM to be run before a mutant's competitive fitness can be evaluated,
and regnans's full-plant community path calls the fitness/selection-gradient
machinery in an order plant now rejects. This is a **regnans↔plant integration
bug in the full-plant assembly path** (regnans's full-plant integration predates
this plant contract), not a documentation issue — and fixing it touches the SCM
assembly algorithm, so it needs the maintainers, not a docs pass.

Once that path works against installed plant, these pages can be finished. A
related crash on the same path — `regr.km` not registered for the bayesopt
fitness method — has already been fixed in regnans
(traitecoevo/regnans#44).

## Secondary cleanups still needed (once the path works)

- Remove dev-machine caching: `saveRDS()`/`readRDS()` to a local `output/` dir,
  including reads of files not in the repo (`output/fitmax-lma-old1.rds`).
- `assembly_stochastic.qmd`: `filename` is undefined at the `saveRDS(...)` on the
  history-fitness chunk; and it `ggsave()`s into a non-existent nested dir.
- `assembly_fitmax.qmd`: the "One trait: Height" section uses an undefined
  `model_support`; `saveRDS`es `obj` (the un-run assembler) rather than the run
  result.
- Several plot objects are assigned but never displayed; show representative ones.
- `solving_attractors.qmd`: ends on an empty "2D attractor" stub (`....`); defines
  `rescale()` twice; the first `plot_sg` is overwritten before it is shown.
- Prose typos throughout ("stocahstic", "attarctor", "euqilibrium", ...).
- `plant_log_console()` in the setup chunks is verbose and can trip the logger's
  glue formatting; drop it for the rendered pages.

## To take live once fixed

`git mv` each back to `theory/adaptive-dynamics/`, add it to the "Adaptive
dynamics" section in `_quarto.yml`, `quarto render`, and commit the `_freeze/`.
