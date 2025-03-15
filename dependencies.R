# dependencies.R

# List of required packages
required_packages <- c("shiny", "stringr", "rvest", "httr", "tidytext", "dplyr", "sentimentr", "DT")

# Function to check, install, and load packages
load_packages <- function(pkg_list) {
  new_packages <- pkg_list[!(pkg_list %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
  for(pkg in pkg_list) library(pkg, character.only = TRUE)
}

# Load the required packages
load_packages(required_packages)
