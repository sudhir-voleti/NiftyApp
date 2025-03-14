# dependencies.R

# Function to check if a package is installed, install if not, and then load it
load_package <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    install.packages(package_name)
  }
  library(package_name, character.only = TRUE)
}

# List of required packages
required_packages <- c("shiny", "dplyr", "tidytext", "stringr")

# Load all required packages
for (pkg in required_packages) {
  load_package(pkg)
}
