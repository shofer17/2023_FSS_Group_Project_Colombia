# Read the NASA light data file
h5ls(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"))
light = h5read(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"),"/HDFEOS/GRIDS/VNP_Grid_DNB/Data Fields")

#read the information: 
#UpperLeftPointMtrs=(-80000000.000000,0.000000)
#LowerRightMtrs=(-70000000.000000,-10000000.000000)
ligth_grid = h5read(paste0(path_raw, "geo_data/VNP46A2.A2023152.h10v08.001.2023160134302.h5"),"/HDFEOS INFORMATION")
# We are on a 2400*2400 Grid. 1 deg. +- 111 km at the equtor. 10 deg = 1110 km. 2400 px --> 1 px is roughly 400-500 meters. 
# 

light <- light$`Gap_Filled_DNB_BRDF-Corrected_NTL`
light <- data.frame(light[, 1800:2400])
light[light == 65535] <- NA
light_sum <- sum(na.omit(light))

#install.packages("sf")
library(sf)

install.packages("raster")
library(rgdal)
library(raster)
library(rhdf5)


# Read the .shp file
shp <- st_read(paste0(path_raw, "shp_files/col-administrative-divisions-shapefiles/col_admbnda_adm1_mgn_20200416.shp"))
shp <- shp %>%
  filter(ADM1_ES %in% c("Putumayo", "Nariño"))

names(G)[3] <- "x"
G_mat <- matrix(G$x)
# Convert the .h5 data to a raster
r <- raster(G_mat)
extent(r) <- extent(shp)

# Crop the raster to the shapefile boundaries
r_crop <- crop(r, shp)

# Now r_crop should contain only the data within the shapefile boundaries
