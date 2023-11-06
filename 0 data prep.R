# Date: 06/11/2023
# Author: Silvan Hofer
# Purpose: Data prep for Group project

setwd("../")

path_raw = "data_raw/"
path_clean = "data_clean/"
path_charts = "charts/"

# Libraries
library(tidyverse)


# 1. Load data ----------

data <- readxl::read_xlsx(paste0(path_raw, 
                                        "Drug Poisoning deaths and rates .xlsx"),
                                 skip = 1)

data_deaths <- data %>% 
  filter(Gender == "Both sexes" &
         Intent == "All (preventable, intentional, undetermined)")%>%
  select(Year, `Drug type`, ...20)%>%
  rename("year" = "Year", "drug" = "Drug type", "number" = "...20")%>%
  filter(number != "All ages" &
         drug %in% c("Cocaine", "Opioid subgroup – including fentanyl"))%>%
  mutate(number = as.numeric(number))

writexl::write_xlsx(data_deaths, path = paste0(path_clean, "death_by_drug.xlsx"))



p <- ggplot(data_deaths, aes(x = year, y = number, color = drug))+
  geom_line()

p

ggsave(paste0(path_charts, "death_by_drug.png"),p)
