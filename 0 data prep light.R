# Purpose: Download and prepare nightlight data in Colombia for analysis. 
# Author: Silvan Hofer
# Date: 17.11.2023

# Please note: The original files are availabe under https://eogdata.mines.edu/nighttime_light/
# Due to storage constraints, the total data amounts to 10 years * 12 months * 2 files * 2 GB/file = +_480GB of storage needed,  
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
library(terra)

setwd("~/FSS_Group_Project_Nightlight")

# 1. Download  Lightdata files unpack them  -------------------------------------
# create df to cycle trough and cover all year-month combinations
# Please note: it is advisable to not run all years at the same time bc. of storage constraints. 

out.check <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
                        "month" = c(paste0("0", 1:9), 10:12),
                        "coordinates" = c("00N180W", "75N180W")) #"00N180W"
out.check$is.available <- NA #check if we downloaded everything
out.check$filename <- NA
out.check$date <- paste0(out.check$year,out.check$month) #
out.check <- out.check %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet


tif <- "tif_files/" # get correct path
tar <- "tar_files/" # get correct path
out.check <- out.check[1:nrow(out.check),]


#go trough all year-month combinations and grab the data file. Then unpack it and save it.
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
    
    data_frames <- lapply(tables, html_table)[[1]] #get the table
    out.check$is.available[i] <- T
    coord <- out.check$coordinates[i] #get the coorect tile
    out.check$filename[i] <- gsub(".tgz",
                                  "", 
                                  data_frames$Name[grepl(coord, data_frames$Name)]
                                  ) #remove "tgz" to load file. Further, take the one that has 'coord' variable name in it as it is correct one
    
    download.file(paste0(url, out.check$filename[i], ".tgz"), 
                  destfile = paste0(tar, out.check$filename[i] ,".tgz")) #download it
    
    untar(tarfile = paste0(tar, paste0(out.check$filename[i], ".tgz")), 
          exdir = tif) #unpack it and save it in a seperate folder
   
     } else {
    out.check$is.available[i] <- F #in case of error indicate it
  }
}

any(!out.check$is.available)  #check if no issues
#writexl::write_xlsx(out.check, "file_overview.xlsx")


# 2.1 Reduce Lightdata files to relevant raster  -------------------------------------
# After downloading the whole dataset, the data is cut to only contain Colombia. 
# This is mainly done to reduce the amount of stored data necessary. 
#out.check <- readxl::read_xlsx("file_overview.xlsx")

# Load shp data for Colombia
shp <- st_read(paste0("shp_files/col-administrative-divisions-shapefiles/col_admbnda_adm1_mgn_20200416.shp"))
all_states <- shp$ADM1_ES[!shp$ADM1_ES %in% c("Archipiélago de San Andrés, 
                                              Providencia y Santa Catalina", 
                                              "Guainía", 
                                              "Vichada")] #remove some states not necessary for analysis. 

# filter for relevant states 
# Here most states, in the final paper only the cocaine cultivating states are analysed
# Computationally, the difference is small compared to loading and processing the
# nightlight data in the first place
shp <- shp %>% 
  filter(ADM1_ES %in% all_states) 

cropbox <- extent(shp) #maximal box needed to contain all relevant states


#get the full downloaded grid, crop, and save it
for (i in 1:nrow(out.check)){
  print(i)
  
  full_grid=raster(paste0(tif, out.check$filename[i], ".avg_rade9h.tif")) 
  crop_grid <- crop(full_grid, cropbox) #reduce to Colombia
  
  raster::writeRaster(x = crop_grid, #save Colombia raster
                      filename=file.path("tif_files_reduced/",
                                         paste0(out.check$year[i],
                                                out.check$month[i],
                                                "_",
                                                coord)
                                         ), 
                      format="GTiff", 
                      overwrite=TRUE)
}

# 2.2 Combine Lightdata from different tiles  ----------------------------------

# create frame to save results in
nl_states <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
                         "month" = c(paste0("0", 1:9), 10:12))
nl_states$date <- paste0(nl_states$year, nl_states$month)
nl_states <- nl_states %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet


# Cycle through all year-month-state combination and combine the two tiles. 
# As Colombia crosses the equator, two tiles (north and south) are necessary to 
# get the whole area of COlombia. The two files are combined here to one. 
for (i in 1:nrow(nl_states)){
  print(i)
  partial_grid_nord=raster(paste0("tif_files_reduced/",nl_dates$year[i],nl_dates$month[i],"_","75N180W", ".tif")) #read in colombia data
  partial_grid_sout=raster(paste0("tif_files_reduced/",nl_dates$year[i],nl_dates$month[i],"_","00N180W", ".tif")) #read in colombia data
  partial_grid <-- raster::merge(partial_grid_sout, partial_grid_nord) #add files together
  partial_grid <- partial_grid*-1 #weird behavior of merge flips signs, flip it back
  
  raster::writeRaster(x = partial_grid, #save colombia raster
                      filename=file.path("tif_files_reduced_combined/",paste0(
                        nl_states$year[i],
                        nl_states$month[i] 
                      )), 
                      format="GTiff", 
                      overwrite=TRUE)
}

# 3. Analyse Lightdata  --------------------------------------------------------
# Data is loaded in and processed.
# Data is analysed with a moving window. So, each datapoint is assigned a new category
# small, medium, large settlement based on the light intensity on the current period. 
# This might induce a bias if some datapoints "jump" categories over time. 
# For this reason, this data is NOT used in the final regression. Instead, data
# from Section 4 (further down), that uses a fixed window from a base year is used to assign 
# datapoints to categories. 

# create frame to save results in
nl_states <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
            "month" = c(paste0("0", 1:9), 10:12),
            "states" = shp$ADM1_ES)
nl_states$date <- paste0(nl_states$year, nl_states$month)
nl_states <- nl_states %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet

nl_dates <- nl_states %>%
  dplyr::select(-states)%>%
  unique()


for (i in 1:nrow(nl_dates)){
  print(i) # Load in data for a certain month
  partial_grid=raster(paste0("tif_files_reduced_combined/",nl_dates$year[i],nl_dates$month[i], ".tif")) #read in colombia data
  
  for(y in 1:length(shp$ADM1_ES)){ #cycle trough states and reduce raster to state
    print(y)
    states_shape <- shp %>%
      filter(ADM1_ES %in% unique(nl_states$states)[y])
    
    cropbox <- extent(states_shape)
    partial_grid_crop <- crop(partial_grid, cropbox) #box around state
    partial_grid_crop <- raster::mask(partial_grid_crop, states_shape) #reduce to state itself
    
    position <- nl_states$date == nl_dates$date[i] & nl_states$states == shp$ADM1_ES[y]# get the correct position to save the values in
    
    nl_states$value_mean[position ] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_max[position] <- max(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_min[position] <- min(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0])
    nl_states$value_band_low[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0.6 & na.omit(values(partial_grid_crop)) <= 3]) #https://www.mdpi.com/2072-4292/14/5/1282
    nl_states$value_band_low_2[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 0.6 & na.omit(values(partial_grid_crop)) <= 5]) #https://www.mdpi.com/2072-4292/14/5/1282
    nl_states$value_band_mid[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) > 3 & na.omit(values(partial_grid_crop)) < 10]) 
    nl_states$value_band_higher[position] <- mean(na.omit(values(partial_grid_crop))[na.omit(values(partial_grid_crop)) >= 10]) 
    
  }
}
writexl::write_xlsx(nl_states, "nl_all_states_new.xlsx")

# save and do some checks 
nl_states_old <- readxl::read_excel("I:/Meine Ablage/2023_FSS_Group_Project/2023_FSS_Group_Project_Colombia/data_clean/nl_states_old.xlsx")
nl_states_old <- nl_states_old %>% filter(year > 2015)
nl_states_new <- nl_states %>% filter(year > 2015) %>% dplyr::select(-value_band_low_2)
test <- nl_states_new[5:ncol(nl_states_new)]-nl_states_old[5:ncol(nl_states_new)]
test$state <- nl_states_new$states
test$date <- nl_states_new$date

# 3. Plot and analysis   -------------------------------------------------------
col <- terrain.colors(10)
brk = c(0.5, 1, 10, 100, 1000, 5000)
image(crop_grid, col = col)
plot(partial_grid, col = col, breaks = brk)

nl_states$date_r <- as.Date(paste0(nl_states$year, "-", nl_states$month, "-01"))

ggplot(nl_states, aes(x = date_r, y = value_mean, color = states))+
  geom_line(aes(color = states))

ggplot(nl_states, aes(x = date_r, y = value_band_low, color = states))+
  geom_line(aes(color = states))



# 4. Robustness: Check pixels switching categories -----------------------------
# Check the robustness of the categories. 
# The possible issue is that if we use luminosity to categorise light sources is smaller/larger cities
# it might not pick up on trends that cross the threshold. E.g. if a village crosses the threshold 
# and the is classified as mid sized, the economic activity would appear to decrease in the small city bracket
# although it actually increased so much that it warrants reclassification. 
# Generally, that should not be too much of an issue as the estiamted effect on economic activity in small cities becomes a
# lower bound and we get already significant effects for this lower bound. With more activity a higher estimation is likely. 
# Still, as a robustness check below the values is calculated based on a by pixel basis starting with base year of 2014. 
# That means we categorise pixels into brackets based on 2014 and then follow them over time. 
# This way the increase/decrease can be tracked across time and the threshold do not influence the further calculations.   

# create frame to save results in
nl_states_rob <- expand.grid("year" = 2012:2023, #prepare frame to cycle trough
                         "month" = c(paste0("0", 1:9), 10:12),
                         "states" = shp$ADM1_ES)
nl_states_rob$date <- paste0(nl_states_rob$year, nl_states_rob$month)
nl_states_rob <- nl_states_rob %>%
  filter(!(year == 2023 & month %in% c("08", "09", 10, 11, 12)))%>% #no data yet
  filter(!(year == 2012 & month %in% c("01", "02", "03"))) #no data yet

nl_dates_rob <- nl_states_rob %>%
  dplyr::select(-states)%>%
  unique()

# read in base year
base_grid=raster(paste0("tif_files_reduced_combined/",2014,"01", ".tif")) #read in colombia data
base_values <- na.omit(values(base_grid)) # get datapoints in base year. 
hist(log(base_values)) #get an idea of distribution
#do the same as in chapter 3, but keep categories stable. 
for (i in 1:nrow(nl_dates_rob)){
  print(i)
  partial_grid=raster(paste0("tif_files_reduced_combined/",nl_dates_rob$year[i],nl_dates_rob$month[i], ".tif")) #read in colombia data

  for(y in 1:length(shp$ADM1_ES)){ #cycle trough states and reduce raster to state
    print(y)
    states_shape <- shp %>%
      filter(ADM1_ES %in% unique(nl_states_rob$states)[y])
    
    cropbox <- extent(states_shape)
    partial_grid_crop <- crop(partial_grid, cropbox) #box around state
    partial_grid_crop <- raster::mask(partial_grid_crop, states_shape) #reduce to state itself
    
    position <- nl_states_rob$date == nl_dates_rob$date[i] & nl_states_rob$states == shp$ADM1_ES[y]# get the correct position to save the values in
    states_values <- values(partial_grid_crop)[!is.na(values(base_grid))] #speed up computing a bit
    
    nl_states_rob$value_mean[position]         <- mean(na.omit(states_values[base_values >= 0]))
    nl_states_rob$value_band_low[position]     <- mean(na.omit(states_values[base_values >= 0.6 & base_values <= 3])) #https://www.mdpi.com/2072-4292/14/5/1282
    nl_states_rob$value_band_mid[position]     <- mean(na.omit(states_values[base_values > 3 & base_values <= 10])) 
    nl_states_rob$value_band_higher[position]  <- mean(na.omit(states_values[base_values > 10]))
  }
}

# Save and do some analysis. 
writexl::write_xlsx(nl_states_rob, "nl_states_new_rob_all.xlsx")


nl_states_rob$date_r <- as.Date(paste0(nl_states_rob$year, "-", nl_states_rob$month, "-01"))
ggplot(nl_states_rob, aes(x = date_r, y = value_mean, color = states))+
  geom_line(aes(color = states))

ggplot(nl_states_rob, aes(x = date_r, y = value_band_mid, color = states))+
  geom_line(aes(color = states))
