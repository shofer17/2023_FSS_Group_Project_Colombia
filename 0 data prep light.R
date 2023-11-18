# Purpose: Download and prepare nightlight data in Colombia for analysis. 
# Author: Silvan Hofer
# Date: 17.11.2023

# Please note: The original files are availabe under https://eogdata.mines.edu/nighttime_light/
# Due to storage constraint, the total data amounts to 10 years * 12 months * 2 files * 2 GB/file = 480GB of storage needed,  
# only project relevant data (covering Colombia) was saved. These files are available upon request (ca. 1.5 GB). 
# However, the below code can be used to download and unpack the original files. 

rm(list = ls())
source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and definitions    

states <- c("Antioquia",  #load coca producing states manually to avoid encoding issues
            "Bolivar","Bolívar",
            "Caqueta","Caquetá", 
            "Cauca", 
            "Cordoba","Córdoba",
            "Putumayo", 
            "Nariño", "Narino", 
            "Norte de Santander"
)

#only load here to avoid always loading specialised packages
library(sf)
library(raster)
library(rvest)

setwd("~/FSS_Group_Project_Nightlight")

# 1. Download  Lightdata files unpack them  -------------------------------------
# create df to cycle trough and cover all year-month combinations
# Please note: it is advisable to not run all years at the same time bc. of storage constraints. 

out.check <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
                        "month" = c(paste0("0", 1:9), 10:12),
                        "coordinates" = c("75N180W")) #"00N180W"
out.check$is.available <- NA #check if we downloaded everything
out.check$filename <- NA
out.check$date <- paste0(out.check$year,out.check$month) #
out.check <- out.check %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet

coord <- "75N180W" #coordinates of tile files 
tif <- "tif_files/" # get correct path
tar <- "tar_files/" # get correct path

#go trough all year-month combinations and grab the data file. Then unpack it and save it
for(i in 1:nrow(out.check)){
  print(i)
  if(out.check$date[i] == "202208"){ #one month has a different link
    url <-  paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                   out.check$year[i], "/",out.check$date[i], "/NOAA-20/vcmslcfg/") 
  } else{
    if(out.check$year[i] > 2013){ #before 2014 the files have different monthly corrections and therefore urls
      url <- paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                    out.check$year[i], "/",out.check$date[i], "/vcmslcfg/")
    }else{
      url <- paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                out.check$year[i], "/",out.check$date[i], "/vcmcfg/")
    }
  }
  
  webpage <- read_html(url) #grab the html of the right page
  tables <- html_nodes(webpage, "table") #the files have some randomness in naming, so extract table with their names and search right one

  if (length(tables) > 0) {
    
    data_frames <- lapply(tables, html_table)[[1]]
    out.check$is.available[i] <- T
    coord <- out.check$coordinates[i]
    out.check$filename[i] <- gsub(".tgz","", data_frames$Name[grepl(coord, data_frames$Name)]) #remove "tgz" to load file. Further, take the one that has 'coord' variable name in it as it is correct one
    #download.file(paste0(url, out.check$filename[i], ".tgz"), destfile = paste0(tar, out.check$filename[i] ,".tgz")) #download it
    #untar(tarfile = paste0(tar, paste0(out.check$filename[i], ".tgz")), exdir = tif) #unpack it and save it in a seperate folder
   
     } else {
    out.check$is.available[i] <- F #in case of error indicate it
  }
}

any(!out.check$is.available)  #check if no issues
writexl::write_xlsx(out.check, "file_overview.xlsx")

# 2. Reduce Lightdata files to relevant raster  -------------------------------------
out.check <- readxl::read_xlsx("file_overview.xlsx")

# Read the .shp file
shp <- st_read(paste0("shp_files/col-administrative-divisions-shapefiles/col_admbnda_adm1_mgn_20200416.shp"))
shp <- shp %>% filter(ADM1_ES %in% states) #filter for relevant states
cropbox <- extent(shp) #maximal box needed to contain all states

for (i in 1:nrow(out.check)){
  print(i)
  full_grid=raster(paste0(tif, out.check$filename[i], ".avg_rade9h.tif")) #get the full downloaded grid
  crop_grid <- crop(full_grid, cropbox) #reduce to colombia
  
  raster::writeRaster(x = crop_grid, #save colombia raster
                      filename=file.path("tif_files_reduced/",paste0(
                        out.check$year[i],
                        out.check$month[i],"_",coord 
                      )), 
                      format="GTiff", 
                      overwrite=TRUE)
}


# 3. Analyse Lightdata  --------------------------------------------------------

# create frame to save results in
nl_states <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
            "month" = c(paste0("0", 1:9), 10:12),
            "states" = shp$ADM1_ES,
            "coordinates" = c("75N180W"))
nl_states$date <- paste0(nl_states$year, nl_states$month)
nl_states <- nl_states %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet




for (i in 1:nrow(out.check)){
  
  partial_grid=raster(paste0("tif_files_reduced/",out.check$year[i],out.check$month[i],"_",coord, ".tif")) #read in colombia data
  
  for(y in 1:length(shp$ADM1_ES)){ #cycle trough states and reduce raster to state
    print(y)
    states_shape <- shp %>%
      filter(ADM1_ES %in% unique(nl_states$states)[y])
    
    cropbox <- extent(states_shape)
    partial_grid_crop <- crop(partial_grid, cropbox) #box around state
    partial_grid_crop <- raster::mask(partial_grid_crop, states_shape) #reduce to state itself
    
    position <- nl_states$date == out.check$date[i] & nl_states$states == shp$ADM1_ES[y]# get the correct position to save the values in
    
    nl_states$value_mean[position ] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_max[position] <- max(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_min[position] <- min(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_band_low[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0.6 & na.omit(values(partial_grid_crop)) <= 3]) #https://www.mdpi.com/2072-4292/14/5/1282
    nl_states$value_band_low[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0.6 & na.omit(values(partial_grid_crop)) <= 5]) #https://www.mdpi.com/2072-4292/14/5/1282
    nl_states$value_band_mid[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0.6 & na.omit(values(partial_grid_crop)) <= 10]) 
    nl_states$value_band_higher[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 3]) 
    
  }
}
writexl::write_xlsx(nl_states, "nl_states_new.xlsx")

nl_states_old <- readxl::read_excel("I:/Meine Ablage/2023_FSS_Group_Project/2023_FSS_Group_Project_Colombia/data_clean/nl_states_old.xlsx")
nl_states_old <- nl_states_old %>% filter(year < 2019)
nl_states <- nl_states %>% filter(year < 2019)
test <- nl_states[5:ncol(nl_states)]-nl_states_old[5:ncol(nl_states)]


# 3. Plot and analysis   -------------------------------------------------------

brk = c(0.5, 1, 10, 100, 1000, 5000)
image(crop_grid, col = col)
plot(crop_grid, col = col, breaks = brk)

nl_states$date_r <- as.Date(paste0(nl_states$year, "-", nl_states$month, "-01", ))

ggplot(nl_states, aes(x = date_r, y = value_mean, color = states))+
  geom_line(aes(color = states))

ggplot(out, aes(x = date_r, y = value_low, color = states))+
  geom_line(aes(color = states))


# archive ----------------------------------------------------------------------
# Code no longer used but potentially useful as code chuncks later


# Seasonality will be done by monthly dummies
# nl_states <- readxl::read_xlsx("nl_states.xlsx")
# #seasonality adjustment
# library(seasonal)
# library(tidyverse)
# base::detach(package:raster)
# 
# nl_states$date_r <- as.Date(paste0(nl_states$year,"-", nl_states$month,"-01"))
# out <- data.frame()
# for(i in 1:length(unique(nl_states$states))){
#   
# 
#   out_loop <- data.frame("date_r" = ts_nl_states$date_r,
#                          "states" = unique(nl_states$states)[i])
#   
#   state_selected <- unique(nl_states$states)[i]
#   ts_nl_states <- nl_states %>%
#     filter(states == state_selected) %>%
#     select(date_r, value_mean, value_max, value_min, value_band_low,value_band_mid,value_band_higher)
#   
#   nm <- names(ts_nl_states)[2:7]
#   
#   
#   for(y in 2:(ncol(ts_nl_states))){
#     ts_loop <- ts_nl_states[, c(1,y)]
#     ts_loop <- ts_loop %>% arrange(ymd(ts_loop$date_r)) %>%
#       select(-date_r)%>%
#       ts(start=c(2016,1), end=c(2023,7), frequency=12)
#     
#     decomp<-decompose(ts_loop)  
#     seasadj <- ts_loop - decomp$seasonal
# 
#     out_loop <- cbind(out_loop, seasadj)
#     
#   }
#   names(out_loop)[3:8] <- nm
#   out <- rbind(out, out_loop)
# }
# writexl::write_xlsx(out, "nl_states_adjusted.xlsx")




# 
# library(rhdf5)
# # Read the NASA light data file
# h5ls(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"))
# light = h5read(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"),"/HDFEOS/GRIDS/VNP_Grid_DNB/Data Fields")
# 
# #read the information: 
# #UpperLeftPointMtrs=(-80000000.000000,0.000000)
# #LowerRightMtrs=(-70000000.000000,-10000000.000000)
# ligth_grid = h5read(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"),"/HDFEOS INFORMATION")
# # We are on a 2400*2400 Grid. 1 deg. +- 111 km at the equtor. 10 deg = 1110 km. 2400 px --> 1 px is roughly 400-500 meters. 
# # 
# 
# light <- light$`Gap_Filled_DNB_BRDF-Corrected_NTL`
# light <- data.frame(light[, 1800:2400])
# light[light == 65535] <- NA
# light_sum <- sum(na.omit(light))