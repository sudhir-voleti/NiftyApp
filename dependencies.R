# dependencies.R

# List of required packages
required_packages <- c("shiny", "quantmod", "DT", "lubridate", "dplyr")

# Function to check and install packages
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# Install and load all required packages
lapply(required_packages, install_if_missing)
