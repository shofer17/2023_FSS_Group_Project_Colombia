rm(list = ls())

source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    


#install.packages("sf")
library(sf)
library(raster)
library(rvest)
library(tidyverse)

setwd("~/FSS_Group_Project_Nightlight")

# Read in Lightdata files and take values  -------------------------------------

# create df to cycle trough and cover all year-month combinations
out.check <- expand.grid("year" = 2016:2023, #prepare frame to cycle trough
                        "month" = c(paste0("0", 1:9), 10:12))
out.check$is.available <- NA #check if we downloaded everything
out.check$filename <- NA
out.check$date <- paste0(out.check$year,out.check$month) #
out.check <- out.check %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12))) #no data yet


#go trough all year-month combinations and grab the data file. Then unpack it and save it
for(i in 1:nrow(out.check)){ #nrow(out.check)
  
  if(out.check$date[i] == "202208"){
    url <-  paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                   out.check$year[i], "/",out.check$date[i], "/NOAA-20/vcmslcfg/") 
  } else{
    url <- paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                out.check$year[i], "/",out.check$date[i], "/vcmslcfg/")
  }
  
  webpage <- read_html(url)
  tables <- html_nodes(webpage, "table")

  if (length(tables) > 0) {
    
    data_frames <- lapply(tables, html_table)[[1]]
    out.check$is.available[i] <- T
    
    out.check$filename[i] <- gsub(".tgz","", data_frames$Name[grepl("75N180W", data_frames$Name)])
    #download.file(paste0(url, out.check$filename[i], ".tgz"), destfile = paste0("tar_files/", out.check$filename[i] ,".tgz"))
    #untar(tarfile = paste0("tar_files/", paste0(out.check$filename[i], ".tgz")), exdir = paste0("tif_files_2/"))
   
     } else {
    out.check$is.available[i] <- F
    }
}

writexl::write_xlsx(out.check, "file_overview.xlsx")
out.check <- readxl::read_xlsx("file_overview.xlsx")

#set wd momentarily back to drive. Data was not stored in drive as it was too much (ca. 50GB)
setwd("I:/Meine Ablage/2023_FSS_Group_Project")
source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    

states <- c("Antioquia", 
            "Bolivar","Bolívar",
            "Caqueta","Caquetá", 
            "Cauca", 
            "Cordoba","Córdoba",
            "Putumayo", 
            "Nariño", "Narino", 
            "Norte de Santander"
)
# Read the .shp file
shp <- st_read(paste0(path_raw, "shp_files/col-administrative-divisions-shapefiles/col_admbnda_adm1_mgn_20200416.shp"))
shp <- shp %>%
  filter(ADM1_ES %in% states)

setwd("~/FSS_Group_Project_Nightlight")

nl_states <- expand.grid("year" = 2016:2023, #prepare frame to cycle trough
            "month" = c(paste0("0", 1:9), 10:12),
            "states" = shp$ADM1_ES)
nl_states$date <- paste0(nl_states$year, nl_states$month)
nl_states <- nl_states %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12))) #no data yet


cropbox <- extent(shp)


for (i in 1:nrow(out.check)){
  print(i)
  if(out.check$year[i] <= 2018){tif <- "tif_files_2/"}else{tif <- "tif_files/"}
  cropbox <- extent(shp)
  full_grid=raster(paste0(tif, out.check$filename[i], ".avg_rade9h.tif"))
  crop_grid <- crop(full_grid, cropbox) #reduce to colombia
  
  for(y in 1:length(shp$ADM1_ES)){
    print(y)
    states_shape <- shp %>%
      filter(ADM1_ES %in% unique(nl_states$states)[y])
    
    cropbox <- extent(states_shape)
    crop_grid <- crop(full_grid, cropbox) #box around state
    crop_grid <- raster::mask(crop_grid, states_shape) #reduce to state itself
    
    position <- nl_states$date == out.check$date[i] & nl_states$states == shp$ADM1_ES[y]
    
    nl_states$value_mean[position ] <- mean(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 0])
    nl_states$value_max[position] <- max(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 0])
    nl_states$value_min[position] <- min(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 0])
    nl_states$value_band_low[position] <- mean(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 0.6 & na.omit(values(crop_grid)) <= 3]) #file:///C:/Users/smhof/Downloads/remotesensing-13-00922.pdf
    nl_states$value_band_mid[position] <- mean(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 0.6 & na.omit(values(crop_grid)) <= 10]) #file:///C:/Users/smhof/Downloads/remotesensing-13-00922.pdf
    nl_states$value_band_higher[position] <- mean(na.omit(values(crop_grid))[na.omit(values(crop_grid)) >= 3]) #file:///C:/Users/smhof/Downloads/remotesensing-13-00922.pdf
    
  }
  rm(crop_grid)
  rm(r_masked)
  writexl::write_xlsx(nl_states, "nl_states.xlsx")
}


nl_states <- readxl::read_xlsx("nl_states.xlsx")
#seasonality adjustment
library(seasonal)
library(tidyverse)
base::detach(package:raster)

nl_states$date_r <- as.Date(paste0(nl_states$year,"-", nl_states$month,"-01"))

out <- data.frame()


for(i in 1:length(unique(nl_states$states))){
  

  out_loop <- data.frame("date_r" = ts_nl_states$date_r,
                         "states" = unique(nl_states$states)[i])
  
  state_selected <- unique(nl_states$states)[i]
  ts_nl_states <- nl_states %>%
    filter(states == state_selected) %>%
    select(date_r, value_mean, value_max, value_min, value_band_low,value_band_mid,value_band_higher)
  
  nm <- names(ts_nl_states)[2:7]
  
  
  for(y in 2:(ncol(ts_nl_states))){
    ts_loop <- ts_nl_states[, c(1,y)]
    ts_loop <- ts_loop %>% arrange(ymd(ts_loop$date_r)) %>%
      select(-date_r)%>%
      ts(start=c(2016,1), end=c(2023,7), frequency=12)
    
    decomp<-decompose(ts_loop)  
    seasadj <- ts_loop - decomp$seasonal

    out_loop <- cbind(out_loop, seasadj)
    
  }
  names(out_loop)[3:8] <- nm
  out <- rbind(out, out_loop)
}

writexl::write_xlsx(out, "nl_states_adjusted.xlsx")


brk = c(0.1, 1, 10, 100, 1000, 5000)
image(imported_raster, col = col)
plot(crop_grid, col = col, breaks = brk)



ggplot(nl_states, aes(x = date_r, y = value_band_low, color = states))+
  geom_line(aes(color = states))

ggplot(out, aes(x = date_r, y = value_band_low, color = states))+
  geom_line(aes(color = states))


# archive ----------------------------------------------------------------------
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