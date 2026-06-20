## Helpers for the plant notebook -------------------------------------
## Source this in a post's setup chunk:  source(here::here("R/version-badge.R"))

#' Render the plant-version / plant-ref front matter as a styled badge.
#'
#' Posts can be built against either branch:
#'   - master  -> declare `plant-version: "2.1.0"` (a released tag)
#'   - develop -> declare `plant-ref: "develop"` and `plant-sha: "a1b2c3d"`
#'
#' A develop post shows the short SHA with a `dev` marker so readers know
#' the result is pinned to a commit, not a release.
#' Call inline:  `r plant_version_badge()`
plant_version_badge <- function(meta = rmarkdown::metadata) {
  ver <- meta[["plant-version"]]
  ref <- meta[["plant-ref"]]
  sha <- meta[["plant-sha"]]

  if (!is.null(ref) && !identical(ref, "master")) {
    # development build: pin to commit
    sha_short <- if (!is.null(sha)) substr(sha, 1, 7) else "unknown"
    return(htmltools::span(
      class = "version-badge version-badge--dev",
      sprintf("plant @%s %s", ref, sha_short)
    ))
  }

  if (is.null(ver)) {
    ver <- tryCatch(as.character(utils::packageVersion("plant")),
                    error = function(e) "unpinned")
  }
  htmltools::span(class = "version-badge", paste0("plant ", ver))
}

#' Print a reproducibility footer: declared ref/version, installed version,
#' commit (for develop builds), and the renv lockfile hash.
plant_session_info <- function(meta = rmarkdown::metadata) {
  ver <- meta[["plant-version"]]
  ref <- meta[["plant-ref"]] %||% "master"
  sha <- meta[["plant-sha"]]
  installed <- tryCatch(as.character(utils::packageVersion("plant")),
                        error = function(e) "not installed")
  lock <- if (file.exists("renv.lock")) {
    substr(digest::digest(file = "renv.lock"), 1, 12)
  } else if (file.exists("renv.lock.dev")) {
    paste0(substr(digest::digest(file = "renv.lock.dev"), 1, 12), " (post-local)")
  } else "no lockfile"

  declared <- if (!identical(ref, "master")) {
    sprintf("%s @ %s", ref, if (!is.null(sha)) substr(sha, 1, 7) else "?")
  } else {
    ver %||% "(none declared)"
  }

  cat(sprintf(
    "plant declared: %s\nplant installed: %s\nrenv.lock: %s\nbuilt: %s\n",
    declared, installed, lock, format(Sys.time(), "%Y-%m-%d")
  ))
}

`%||%` <- function(a, b) if (is.null(a)) b else a
