#!/usr/bin/env Rscript
# Resolve a refresh target to a list of post directories (one per line).
#   --scope category --target reproduction  -> all posts with that category
#   --scope glob     --target "2026-06-*"   -> posts matching the glob
# Prints post paths relative to repo root (e.g. posts/2026-06-20-foo).

args <- commandArgs(trailingOnly = TRUE)
get <- function(flag, default = NULL) {
  i <- which(args == flag)
  if (length(i) && i < length(args)) args[[i + 1]] else default
}
scope  <- get("--scope", "category")
target <- get("--target", "")

post_dirs <- list.dirs("posts", recursive = FALSE)
post_dirs <- post_dirs[file.exists(file.path(post_dirs, "index.qmd"))]
# skip templates (leading underscore)
post_dirs <- post_dirs[!grepl("/_", post_dirs)]

read_front_matter <- function(qmd) {
  lines <- readLines(qmd, warn = FALSE)
  fm <- which(lines == "---")
  if (length(fm) < 2) return(character())
  lines[(fm[1] + 1):(fm[2] - 1)]
}

matches <- character()
for (d in post_dirs) {
  fm <- read_front_matter(file.path(d, "index.qmd"))
  if (scope == "category") {
    cats_line <- grep("^categories:", fm, value = TRUE)
    if (length(cats_line) && grepl(target, cats_line, fixed = TRUE)) {
      matches <- c(matches, d)
    }
  } else { # glob
    if (grepl(utils::glob2rx(target), basename(d))) {
      matches <- c(matches, d)
    }
  }
}
cat(matches, sep = "\n")
if (length(matches)) cat("\n")
