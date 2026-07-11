# Staged: full-plant assembly vignettes

These three worked-example vignettes are held back from the live site (this
`_staging/` directory is a leading-underscore path Quarto does not render). The
rest of the adaptive-dynamics section — the toy-model write-ups
(DD99/GK98/GM99/JJ12), the section index, and the main `assembly.qmd` — is live
under `theory/adaptive-dynamics/`.

- `assembly_fitmax.qmd` — max-fitness assembly (1- and 2-trait)
- `assembly_stochastic.qmd` — stochastic assembly
- `solving_attractors.qmd` — selection gradients and solving for attractors

## Primary blocker: a plant regression breaks mutant fitness (plant#564)

Unlike `assembly.qmd` (which uses the fast **toy models** — `harness_dd99` etc.),
these three drive the **full `plant` SCM** assembly via
`plant_default_assembly_pars()`. Against current plant `develop`, computing a
mutant's fitness / selection gradient fails with:

```
Error: Run a resident first to generate a competitve landscape
```

thrown in plant C++ (`inst/include/plant/patch.h`, `Patch::set_mutant()`).

This is **not** a regnans or docs bug — it is a plant regression, filed as
**traitecoevo/plant#564**. plant's mutant-fitness replay (#362) relies on caching
the resident's per-RK-step environments during the resident run, via three
`Patch` hooks (`cache_RK45_step`, `cache_ode_step`, `load_ode_step`). The odelia
migration (#456) deleted plant's own ODE solver — which called those hooks — and
swapped in odelia, which never calls them, so they are now dead code and
`environment_history` is always empty. plant's own `tests/testthat/test-mutant.R`
fails as a result. regnans (via `plant_community_update_fitness_function`)
correctly sets `save_RK45_cache = TRUE` and runs the resident first; the cache
just never gets populated underneath it.

Once plant#564 is fixed, these pages should render. A related crash on the same
path — `regr.km` not registered for the bayesopt fitness method — has already
been fixed in regnans (traitecoevo/regnans#44).

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
