# dependencies.R
# Check, install, and load required packages.

packages <- c("shiny", "tidytext", "dplyr", "stringr", "textdata", "DT", "ggplot2", "plotly")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}
