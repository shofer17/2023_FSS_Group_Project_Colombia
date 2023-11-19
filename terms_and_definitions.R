# This document provides all shared terms and definitions for the project. 
# Additionally, libraries and system changes are included to make life easier. 



#sys definitions
Sys.setenv(LANGUAGE="en")

#paths
path_raw = "data_raw/"
path_clean = "2023_FSS_Group_Project_Colombia/data_clean/"
path_charts = "charts/"
path_processing = "2023_FSS_Group_Project_Colombia/Data_processing/"


# variables

states <- c("Antioquia", 
            "Bolivar","Bolívar",
            "Caqueta","Caquetá", 
            "Cauca", 
            "Cordoba","Córdoba",
            "Putumayo", 
            "Nariño", "Narino", 
            "Norte de Santander"
            )


states_key <- data.frame(states =  c("Nariño", "Putumayo", "Norte de Santander","Cauca","Antioquia","Bolívar", "Córdoba","Caquetá","Chocó","Guaviare"),
                     DPTO = c(52,86, 54,19,05,13,23,18,27,95))



#colors
col <- terrain.colors(10)

# Libraries
library(tidyverse)
library(haven)
library(sqldf)
# install.packages("BiocManager")
# BiocManager::install("rhdf5")
library(rhdf5)


