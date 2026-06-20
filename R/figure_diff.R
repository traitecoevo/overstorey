#!/usr/bin/env Rscript
# Crude-but-useful figure drift report. Compares PNGs under two trees by
# content hash; lists figures that changed, appeared, or vanished.
# Usage: Rscript R/figure_diff.R <before_dir> <after_dir>
# Prints Markdown to stdout.

args <- commandArgs(trailingOnly = TRUE)
before <- args[[1]]; after <- args[[2]]

hash_pngs <- function(root) {
  fs <- list.files(root, pattern = "\\.png$", recursive = TRUE, full.names = TRUE)
  # normalise key to the path relative to root
  keys <- sub(paste0("^", normalizePath(root, mustWork = FALSE), "/?"), "", normalizePath(fs))
  # strip a leading _freeze/ or before-snapshot prefix so keys align
  keys <- sub("^.*_freeze/", "", keys)
  setNames(vapply(fs, function(f) tryCatch(digest::digest(file = f), error = function(e) NA_character_), ""), keys)
}

b <- hash_pngs(before)
a <- hash_pngs(after)

all_keys <- union(names(b), names(a))
changed <- new <- gone <- character()
for (k in all_keys) {
  if (is.na(b[k]) || is.null(b[[k]])) new <- c(new, k)
  else if (is.na(a[k]) || is.null(a[[k]])) gone <- c(gone, k)
  else if (!identical(b[[k]], a[[k]])) changed <- c(changed, k)
}

cat("## Model drift watch\n\n")
cat(sprintf("plant master HEAD · %s\n\n", format(Sys.time(), "%Y-%m-%d %H:%M UTC")))

emit <- function(title, v) {
  cat(sprintf("### %s (%d)\n\n", title, length(v)))
  if (!length(v)) { cat("_none_\n\n"); return(invisible()) }
  for (x in sort(v)) cat("- `", x, "`\n", sep = "")
  cat("\n")
}
emit("Figures that CHANGED", changed)
emit("New figures", new)
emit("Figures that disappeared", gone)

if (length(changed)) {
  cat("> Changed figures mean a reproduction result moved against current ",
      "plant. Investigate before re-pinning published posts.\n", sep = "")
}
