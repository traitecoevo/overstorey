# Staged: adaptive-dynamics section (regnans toy models)

These pages document the fast toy adaptive-dynamics models in
[`regnans`](https://github.com/traitecoevo/regnans) — per-model write-ups
(DD99/GK98/GM99/JJ12), the community-assembly examples, and the attractor solver.

They live under `_staging/` (a leading-underscore directory Quarto does not
render) because they are **not yet publishable on the site**. Two things are
needed first:

1. **regnans must export the workflow verbs these pages use.** The pages call
   `community_add()`, `assembler_set_traits()`, and
   `plant_default_assembly_pars()`, which are currently internal to regnans
   (defined but not in its `NAMESPACE`). They were written to run under
   `devtools::load_all()`, which exposes every internal function. Once regnans
   exports them (or provides public equivalents), the pages render against the
   installed package.

2. **regnans must be added to the site's `renv.lock`.** It is not currently a
   recorded dependency of the overstorey site.

To take them live once both are done:

- `git mv _staging/adaptive-dynamics theory/adaptive-dynamics`
- add an "Adaptive dynamics" section to the Theory sidebar in `_quarto.yml`
  (lead with `theory/adaptive-dynamics.qmd`, then `index.qmd`, the four model
  pages, the three `assembly*` pages, and `solving_attractors.qmd`)
- `quarto render` and commit the generated `_freeze/` entries

The dev-environment `devtools::load_all()` calls have already been removed from
these files; they otherwise render once the regnans API above is in place.
