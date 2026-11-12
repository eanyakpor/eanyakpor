# Run the full analysis from the project root in RStudio:
#   source("R/run_all.R")

source("R/install_packages.R")
source("R/00_setup_and_clean.R")
source("R/01_correlation.R")
source("R/02_anova.R")
source("R/03_regression.R")
message("Done. Figures are in output/")
