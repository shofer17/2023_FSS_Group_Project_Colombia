# This document provides all shared terms and definitions for the project. 
# Additionally, libraries and system changes are included to make life easier. 



#sys definitions
Sys.setenv(LANGUAGE="en")

#paths
path_raw = "data_raw/"
path_clean = "2023_FSS_Group_Project_Colombia/data_clean/"
path_charts = "charts/"

# Libraries
library(tidyverse)
library(haven)
library(sqldf)
# install.packages("BiocManager")
# BiocManager::install("rhdf5")
library(rhdf5)

