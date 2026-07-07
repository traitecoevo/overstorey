#!/usr/bin/env Rscript
# Docs-vs-model coverage drift. Enumerates plant's live public surface
# (strategies, per-strategy ODE states + parameters, exported functions) and
# diffs it against a committed baseline manifest. New surface = features plant
# grew that the docs may not cover yet — exactly the class of drift (soil water,
# TF24f's opt_root_psi_state, new drivers) that only got caught by hand before.
#
# Usage:
#   Rscript R/coverage_check.R                 # check: diff live plant vs baseline, print Markdown
#   Rscript R/coverage_check.R --update        # (re)write the baseline from live plant
#   Rscript R/coverage_check.R --strict        # check, but exit 1 if any drift is found
#   Rscript R/coverage_check.R --manifest PATH # use a non-default manifest path
#
# Requires `plant` to be installed (fails loudly otherwise). Commits nothing;
# like figure_diff.R it just reports. On first run with no baseline it writes
# one and tells you to commit it. Re-bless the baseline with --update once the
# docs have caught up with the reported drift.

`%||%` <- function(a, b) if (is.null(a)) b else a

args <- commandArgs(trailingOnly = TRUE)
flag <- function(f) f %in% args
opt  <- function(f, default = NULL) {
  i <- which(args == f)
  if (length(i) && i < length(args)) args[[i + 1]] else default
}

manifest_path <- opt("--manifest", "R/coverage-manifest.json")
do_update     <- flag("--update")
strict        <- flag("--strict")

# --- Enumerate plant's live surface -----------------------------------------
plant_surface <- function() {
  if (!requireNamespace("plant", quietly = TRUE)) {
    stop("plant is not installed; cannot enumerate its surface. ",
         "Install it (e.g. renv::install(\"traitecoevo/plant@develop\")) first.",
         call. = FALSE)
  }
  exports    <- sort(getNamespaceExports("plant"))
  strategies <- sort(sub("_Strategy$", "", grep("_Strategy$", exports, value = TRUE)))

  ode <- list(); params <- list()
  for (s in strategies) {
    ode[[s]] <- tryCatch(
      sort(get(paste0(s, "_Individual"))()$ode_names),
      error = function(e) paste0("<introspection error: ", conditionMessage(e), ">"))
    params[[s]] <- tryCatch(
      sort(names(get(paste0(s, "_Strategy"))()$pars)),
      error = function(e) paste0("<introspection error: ", conditionMessage(e), ">"))
  }

  list(
    plant_version = as.character(utils::packageVersion("plant")),
    generated     = format(Sys.time(), "%Y-%m-%d %H:%M UTC"),
    strategies    = strategies,
    ode_names     = ode,
    params        = params,
    exports       = exports
  )
}

write_manifest <- function(surface, path) {
  jsonlite::write_json(surface, path, pretty = TRUE, auto_unbox = TRUE)
}

# --- Update mode -------------------------------------------------------------
if (do_update) {
  s <- plant_surface()
  write_manifest(s, manifest_path)
  cat(sprintf("Wrote baseline manifest %s (plant %s, %d strategies).\n",
              manifest_path, s$plant_version, length(s$strategies)))
  quit(status = 0)
}

live <- plant_surface()

# --- Bootstrap: no baseline yet ---------------------------------------------
if (!file.exists(manifest_path)) {
  write_manifest(live, manifest_path)
  cat("## Docs coverage drift\n\n")
  cat(sprintf("No baseline manifest found. Wrote one from plant %s at `%s`.\n\n",
              live$plant_version, manifest_path))
  cat("> First run: this captured plant's current surface as the documented\n",
      "> baseline. Commit `", manifest_path, "` so future runs can diff against\n",
      "> it. Re-bless with `Rscript R/coverage_check.R --update` whenever the\n",
      "> docs have caught up with newly reported surface.\n", sep = "")
  quit(status = 0)
}

base <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)

# --- Diff --------------------------------------------------------------------
set_diff <- function(live_v, base_v) {
  live_v <- as.character(live_v); base_v <- as.character(base_v)
  list(added = setdiff(live_v, base_v), removed = setdiff(base_v, live_v))
}
# Per-strategy map diff -> named vector "STRATEGY: item"
map_diff <- function(live_map, base_map, which) {
  keys <- union(names(live_map), names(base_map))
  out <- character()
  for (k in keys) {
    d <- set_diff(live_map[[k]] %||% character(), base_map[[k]] %||% character())
    for (x in d[[which]]) out <- c(out, sprintf("%s: %s", k, x))
  }
  sort(out)
}

strat  <- set_diff(live$strategies, base$strategies)
ode_added   <- map_diff(live$ode_names, base$ode_names, "added")
ode_removed <- map_diff(live$ode_names, base$ode_names, "removed")
par_added   <- map_diff(live$params,    base$params,    "added")
par_removed <- map_diff(live$params,    base$params,    "removed")
exp          <- set_diff(live$exports, base$exports)

n_new  <- length(strat$added) + length(ode_added) + length(par_added) + length(exp$added)
n_gone <- length(strat$removed) + length(ode_removed) + length(par_removed) + length(exp$removed)

# --- Report ------------------------------------------------------------------
cat("## Docs coverage drift\n\n")
cat(sprintf("plant `%s` (live) vs documented baseline `%s` · %s\n\n",
            live$plant_version, base$plant_version %||% "?", live$generated))

emit <- function(title, v) {
  cat(sprintf("### %s (%d)\n\n", title, length(v)))
  if (!length(v)) { cat("_none_\n\n"); return(invisible()) }
  for (x in v) cat("- `", x, "`\n", sep = "")
  cat("\n")
}

cat("## New in plant, not yet in the baseline\n\n")
emit("New strategies", strat$added)
emit("New ODE states", ode_added)
emit("New parameters", par_added)
emit("New exported functions", exp$added)

cat("## Gone from plant, still in the baseline\n\n")
emit("Removed strategies", strat$removed)
emit("Removed ODE states", ode_removed)
emit("Removed parameters", par_removed)
emit("Removed exported functions", exp$removed)

if (n_new) {
  cat("> New surface means plant grew features the docs may not cover yet.\n",
      "> Reconcile the docs, then re-bless the baseline with\n",
      "> `Rscript R/coverage_check.R --update` and commit the manifest.\n", sep = "")
} else if (n_gone) {
  cat("> Surface disappeared: the docs may describe something plant removed or\n",
      "> renamed. Check, fix the docs, then re-bless with `--update`.\n", sep = "")
} else {
  cat("No coverage drift: the docs' baseline matches plant's live surface.\n")
}

if (strict && (n_new || n_gone)) quit(status = 1)
