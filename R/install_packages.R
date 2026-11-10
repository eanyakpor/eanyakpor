# Run once in RStudio: source("R/install_packages.R")

pkgs <- c("tidyverse", "broom", "car", "hexbin")
need <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(need)) install.packages(need)
message("Packages ready: ", paste(pkgs, collapse = ", "))
