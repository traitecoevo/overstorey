#!/usr/bin/env Rscript
# Fail if any *published* reproduction post is half-finished.
# (R port of the former check_reproductions.py — plant is an R shop, so the
#  lint shouldn't drag in a Python + PyYAML toolchain. Uses the `yaml`
#  package, which is already a project dependency.)
#
# A reproduction post (category includes 'reproduction', not under posts/_*)
# must, before it can merge:
#   - be pinned: either plant-version OR (plant-ref + plant-sha)
#   - declare fidelity other than 'pending'
#   - have no 'TODO' anywhere in its paper: block or top-level pins
#
# Anything under posts/_* (templates, drafts) is exempt.

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("the 'yaml' package is required for the reproduction lint", call. = FALSE)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
nonempty <- function(x) !is.null(x) && length(x) > 0 && any(nzchar(as.character(x)))

# Extract and parse the YAML front matter (between the first two --- fences).
front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (length(lines) == 0 || !grepl("^---\\s*$", lines[1])) return(NULL)
  fences <- which(grepl("^---\\s*$", lines))
  if (length(fences) < 2) return(NULL)
  block <- lines[(fences[1] + 1):(fences[2] - 1)]
  tryCatch(yaml::yaml.load(paste(block, collapse = "\n")),
           error = function(e) NULL)
}

errors <- character()
paths <- list.files("posts", pattern = "^index\\.qmd$",
                    recursive = TRUE, full.names = TRUE)

for (path in paths) {
  if (grepl("/_", path)) next                 # skip templates / drafts
  meta <- front_matter(path)
  if (is.null(meta)) next
  cats <- as.character(meta[["categories"]] %||% character())
  if (!("reproduction" %in% cats)) next

  # 1) pinning: a release version, or a develop ref + commit
  has_version <- nonempty(meta[["plant-version"]])
  has_ref     <- nonempty(meta[["plant-ref"]]) && nonempty(meta[["plant-sha"]])
  if (!(has_version || has_ref)) {
    errors <- c(errors, sprintf(
      "%s: not pinned (need plant-version OR plant-ref+plant-sha)", path))
  }

  paper <- meta[["paper"]] %||% list()

  # 2) fidelity decided
  fidelity <- tolower(as.character(paper[["fidelity"]] %||% "pending"))
  if (identical(fidelity, "pending")) {
    errors <- c(errors, sprintf("%s: paper.fidelity is still 'pending'", path))
  }

  # 3) no TODOs left in the metadata that drives the citation/badges
  pins <- vapply(c("plant-version", "plant-ref", "plant-sha"),
                 function(k) sprintf("%s: %s", k, as.character(meta[[k]] %||% "")),
                 character(1))
  paper_blob <- if (length(paper)) yaml::as.yaml(paper) else ""
  blob <- paste(c(paper_blob, pins), collapse = "\n")
  if (grepl("\\bTODO\\b", blob)) {
    bad <- names(paper)[vapply(paper,
      function(v) is.character(v) && any(grepl("TODO", v)), logical(1))]
    where <- if (length(bad)) paste(bad, collapse = ", ") else "see pins"
    errors <- c(errors, sprintf("%s: TODO left in paper block: %s", path, where))
  }
}

if (length(errors)) {
  cat("Reproduction lint failed:\n\n")
  for (e in errors) cat("  -", e, "\n")
  cat("\n(Drafts: keep them under posts/_drafts/ or omit the",
      "'reproduction' category until ready.)\n")
  quit(status = 1)
}

cat("All reproduction posts are complete and pinned.\n")
