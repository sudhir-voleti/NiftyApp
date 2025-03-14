# dependencies.R

# List of required packages
required_packages <- c("shiny", "readr", "dplyr", "stringr")

# Function to check and install packages
check_and_install <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    install.packages(package_name)
  }
  
# Install and load required packages
for (pkg in required_packages) {
  check_and_install(pkg)
}

# Load required libraries directly
library('shiny')
library('readr')
library('dplyr')
library('stringr')

cat("All required packages have been checked and loaded.\n")

