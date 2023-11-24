# Date: 06/11/2023
# Author: Silvan Hofer
# Purpose: Data prep for Group project
# Please note: Due to the data size, the raw data was loaded from the desktop
# and not from the cloud. The data was downloaded from: 
# https://www.nber.org/research/data/mortality-data-vital-statistics-nchs-multiple-cause-death-data
# and then processed using the code below. 

setwd("I:/Meine Ablage/2023_FSS_Group_Project")
source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    
setwd("~/FSS_Group_Project_Nightlight")

years <- 2012:2021
out <- data.frame()

# The loop loads in all full mortality file one by one, then processes it and then
# adds the output to the "out" frame. The "out" frame represents the final data
# which is also uploaded to GitHub. 
for(i in 1:length(years)){
  
  path <- paste0("mortality_files/mort", years[i], ".csv")
  
  data_loop <- read_csv(path)
  data_loop$id <- 1:nrow(data_loop)
  data_loop<- data_loop[,grepl("enicon|monthdth|year|id", names(data_loop))] #grab relevant variables
  
  data_loop$is_cocaine <- apply(data_loop, 1, FUN = function(x) any(na.omit(x) == "T405")) #grab deaths related to cocaine and fentanyl
  data_loop$is_fentanyl <- apply(data_loop, 1, FUN = function(x) any(na.omit(x) == "T404"))
  
  
  data_loop_2 <- data_loop %>%
    filter(is_cocaine | is_fentanyl)
  
  data_loop_cocaine <- aggregate(data = data_loop_2, id ~monthdth + year + is_cocaine, FUN = function(x) length(unique(x)))
  data_loop_cocaine <- data_loop_cocaine %>% pivot_wider(names_from = 3, values_from = 4)
  names(data_loop_cocaine)[4] <- "cocain_related_deaths"
  names(data_loop_cocaine)[3] <- "only_fentanyl_related"
  
  data_loop_fentanyl <- aggregate(data = data_loop_2, id ~monthdth + year + is_fentanyl, FUN = function(x) length(unique(x)))
  data_loop_fentanyl <- data_loop_fentanyl %>% pivot_wider(names_from = 3, values_from = 4)
  names(data_loop_fentanyl)[4] <- "fentanyl_related_deaths"
  names(data_loop_fentanyl)[3] <- "only_cocaine_related"
  
  data_out <- merge(data_loop_cocaine, data_loop_fentanyl, by = c("monthdth", "year"))
  out <- rbind(out, data_out)
  
  rm(data_loop)
}




writexl::write_xlsx(out, path = "mortality_cocaine_fentanyl.xlsx")
