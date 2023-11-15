rm(list = ls())

source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    


#install.packages("sf")
library(sf)
library(rgdal)
library(raster)
library(rvest)

# Read in Lightdata files and take values  -------------------------------------

setwd("~/FSS_Group_Project_Nightlight")

out.check <- expand.grid("year" = 2019:2023, #prepare frame to cycle trough
                        "month" = c(paste0("0", 1:9), 10:12))
out.check$is.available <- NA #check if we downloaded everything
out.check$date <- paste0(out.check$year,out.check$month) #
out.check$filename <- NA
out.check$value_mean <- NA
out.check$value_max <- NA
out.check$value_min <- NA
out.check$value_band <- NA


for(i in 6:nrow(out.check)){ #nrow(out.check)
  url <- paste0("https://eogdata.mines.edu/nighttime_light/monthly/v10/", 
                out.check$year[i], "/",out.check$date[i], "/vcmslcfg/")
  
  webpage <- read_html(url)
  tables <- html_nodes(webpage, "table")

  if (length(tables) > 0) {
    
    data_frames <- lapply(tables, html_table)[[1]]
    out.check$is.available[i] <- T
    
    out.check$filename[i] <- gsub(".tgz","", data_frames$Name[grepl("75N180W", data_frames$Name)])
    download.file(paste0(url, out.check$filename[i], ".tgz"), destfile = paste0("tar_files/", out.check$filename[i] ,".tgz"))
    
    
    untar(tarfile = paste0("tar_files/", paste0(out.check$filename[i], ".tgz")), exdir = paste0("tif_files/"))
    
    
    } else {
    out.check$is.available[i] <- F
    }
}


# Read the .shp file
shp <- st_read(paste0(path_raw, "shp_files/col-administrative-divisions-shapefiles/col_admbnda_adm1_mgn_20200416.shp"))
shp <- shp %>%
  filter(ADM1_ES %in% states)


brk = c(0.1, 1, 10, 100, 1000, 5000)
cropbox <- extent(shp)



for (i in 1:5){
  full_grid=raster(paste0("tif_files/", out.check$filename[i], ".avg_rade9h.tif"))
  crop_grid <- crop(full_grid, cropbox)
  out.check$value_mean[i] <- mean(values(crop_grid)[values(crop_grid) >= 0])
  out.check$value_max[i] <- max(values(crop_grid)[values(crop_grid) >= 0])
  out.check$value_min[i] <- min(values(crop_grid)[values(crop_grid) >= 0])
  out.check$value_band[i] <- mean(values(crop_grid)[values(crop_grid) >= 0.6 & values(crop_grid) <= 3])
}


image(imported_raster, col = col)
plot(imported_raster_crop, col = col, breaks = brk)


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