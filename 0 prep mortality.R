setwd("I:/Meine Ablage/2023_FSS_Group_Project")
source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    


setwd("~/FSS_Group_Project_Nightlight")

years <- 2016:2021
out <- data.frame()
for(i in 1:length(years)){
  
  path <- paste0("mortality_files/mort", years[i], ".csv")
  
  data_loop <- read_csv(path)
  data_loop$id <- 1:nrow(data_loop)
  data_loop<- data_loop[,grepl("enicon|monthdth|year|id", names(data_loop))]
  
  data_loop$is_cocaine <- apply(data_loop, 1, FUN = function(x) any(na.omit(x) == "T405"))
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




