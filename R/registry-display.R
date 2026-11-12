# Displays rendered from plant's model registry (plant::model_registry()), so a
# page's equation is the registry's record of what the code computes rather
# than a copy that can drift from it. An id of the form "phylloptim:<id>" is
# taken from phylloptim's registry, which plant links to.
#
# Call from a chunk with `output: asis`; the label keeps the display's
# cross-reference (@eq-...) working:
#
#   ```{r}
#   #| echo: false
#   #| output: asis
#   registry_display("FF16.net_production", "eq-dbdt")
#   ```
registry_display <- local({
  reg <- NULL
  function(id, label = NULL) {
    if (is.null(reg)) reg <<- plant::model_registry()
    tex <- trimws(plant::registry_equation(id, registry = reg))
    cat("\n$$\n", tex, "\n$$", if (!is.null(label)) paste0(" {#", label, "}"),
        "\n\n", sep = "")
  }
})
