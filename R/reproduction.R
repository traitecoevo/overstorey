## Helpers for reproduction posts -------------------------------------
## source(here::here("R/reproduction.R")) in a post's setup chunk.

`%||%` <- function(a, b) if (is.null(a)) b else a

#' Render the `paper:` front-matter block as a citation box.
paper_citation <- function(meta = rmarkdown::metadata) {
  p <- meta[["paper"]]
  if (is.null(p)) return(htmltools::HTML(""))
  doi_link <- if (!is.null(p$doi) && nzchar(p$doi) && p$doi != "TODO") {
    sprintf('<a href="https://doi.org/%s">%s</a>', p$doi, p$doi)
  } else "<em>doi: TODO</em>"
  htmltools::HTML(sprintf(
    '<div class="paper-cite">
       <span class="paper-cite__label">reproducing</span>
       <span class="paper-cite__ref">%s (%s). <em>%s</em>. %s.</span>
       <span class="paper-cite__fig">%s</span>
       <span class="paper-cite__doi">%s</span>
     </div>',
    p$authors %||% "TODO", p$year %||% "TODO", p$title %||% "TODO",
    p$journal %||% "TODO", p$figure %||% "TODO", doi_link
  ))
}

#' Render a fidelity verdict badge from paper$fidelity.
#' pending | matches | differs | approximate
repro_fidelity_badge <- function(meta = rmarkdown::metadata) {
  f <- (meta[["paper"]]$fidelity) %||% "pending"
  cls <- switch(f,
    matches     = "fidelity--match",
    differs     = "fidelity--differ",
    approximate = "fidelity--approx",
    "fidelity--pending")
  label <- switch(f,
    matches     = "reproduces",
    differs     = "differs",
    approximate = "approximate",
    "pending")
  htmltools::span(class = paste("fidelity-badge", cls), label)
}

#' Render a badge for the original paper's code provenance, if pinned.
#' Shows repo @ short-ref so a reader knows the exact tree behind the
#' "paper code, today" re-run. Returns empty if code-repo is unset/TODO.
paper_code_badge <- function(meta = rmarkdown::metadata) {
  p <- meta[["paper"]]
  repo <- p[["code-repo"]]
  ref  <- p[["code-ref"]]
  if (is.null(repo) || !nzchar(repo) || repo == "TODO") {
    return(htmltools::HTML(""))
  }
  ref_short <- if (!is.null(ref) && nzchar(ref) && ref != "TODO") {
    if (grepl("^[0-9a-f]{20,}$", ref)) substr(ref, 1, 7) else ref
  } else "?"
  href <- sprintf("https://github.com/%s/tree/%s", repo, ref %||% "")
  htmltools::HTML(sprintf(
    '<a class="version-badge version-badge--code" href="%s">%s @%s</a>',
    href, repo, ref_short
  ))
}
