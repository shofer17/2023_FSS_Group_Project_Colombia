# Date: 06/11/2023
# Author: Silvan Hofer
# Purpose: Data prep for Group project

setwd("../") #set the working environment to "2023_FSS_Group_Project"
source("2023_FSS_Group_Project_Colombia/terms_and_definitions.R") #load in common terms and defintions    

limit  <- 100000 # dataset has 60k rows, 100k should get all data

# 1. Load data ----------------------------------------------------------------- 
## 1.1 Death data --------------------------------------------------------------
#https://www.cdc.gov/nchs/nvss/mortality_public_use_data.htm
data_deaths_complete <- read_table(paste0(path_raw, "Mort2018US.PubUse.txt")) 
data_deaths_complete_2 <- read.csv(paste0(path_raw, "Mort2018US.PubUse.txt")) 

# https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a
data_VSRR <- read.csv("https://data.cdc.gov/resource/xkb8-kh2a.csv?$limit=100000")

# https://injuryfacts.nsc.org/home-and-community/safety-topics/drugoverdoses/data-details/
data_injuryfacts <- readxl::read_xlsx(paste0(path_raw, 
                                        "Drug Poisoning deaths and rates .xlsx"),
                                 skip = 1)

## 1.2 Drug data --------------------------------------------------------------

drugs_nw_20_23 <- read.csv(paste0(path_raw, "nationwide-drugs-fy20-fy23.csv"))
drugs_nw_19_22 <- read.csv(paste0(path_raw, "nationwide-drugs-fy19-fy22.csv"))

drugs_amo_20_23 <- read.csv(paste0(path_raw, "amo-drug-seizures-fy20-fy23.csv"))
drugs_amo_19_22 <- read.csv(paste0(path_raw, "amo-drug-seizures-fy19-fy22.csv"))


# 2. prep data -----------------------------------------------------------------
# 2.1 deaths -----------------------------------------------------------------

data_VSRR_prov <- data_VSRR %>%
  mutate(year_month = paste0(year, "_", month))%>%
  select(year_month, indicator, data_value)%>%
  filter(indicator %in% c("Synthetic opioids, excl. methadone (T40.4)", "Cocaine (T40.5)"))

data_injuryfacts <- data_injuryfacts %>% 
  filter(Gender == "Both sexes" &
         Intent == "All (preventable, intentional, undetermined)")%>%
  select(Year, `Drug type`, ...20)%>%
  rename("year" = "Year", "drug" = "Drug type", "number" = "...20")%>%
  filter(number != "All ages" &
         drug %in% c("Cocaine", "Opioid subgroup – including fentanyl"))%>%
  mutate(number = as.numeric(number))

# 2.2 drugs seized -----------------------------------------------------------------

drugs_amo_19_22 <- drugs_amo_19_22 %>% select(-Branch) %>% filter(FY == 2019)
drugs_amo_20_23 <- drugs_amo_20_23 %>% select(-Branch)
drugs_nw_19_22 <- drugs_nw_19_22 %>% select(-Area.of.Responsibility)%>% filter(FY == 2019)
drugs_nw_20_23 <- drugs_nw_20_23 %>% select(-Area.of.Responsibility)
drugs <- unique(rbind(drugs_amo_19_22, drugs_amo_20_23, drugs_nw_19_22, drugs_nw_20_23))



months <- data.frame("month" = c("JAN","FEB","MAR","APR","MAY","JUN", "JUL", "AUG","SEP","OCT","NOV","DEC"),
                     "month_num" = c(paste0("0", 1:9),10:12))

drugs <- drugs %>%
    rename("year" = "FY", "month" = "Month..abbv.", "drug" = "Drug.Type", "quantity" = "Sum.Qty..lbs.")%>%
    select(year,month, drug, quantity)%>%
    filter(drug %in% c("Cocaine", "Fentanyl"))%>%
    group_by(year, month, drug)%>%
    summarise(kg = sum(quantity))%>%
    ungroup()%>%
    left_join(months, by = "month")%>%
    mutate(date = dmy(paste0("1-",month_num,"-", year)))%>% #for plotting
    mutate(date_stata = paste0(year,month_num))%>% #for merge with stata
    select(-c(year, month_num,month))



rm(drugs_amo, drugs_amo_19_22, drugs_amo_20_23, drugs_nw, drugs_nw_20_23, drugs_nw_19_22, months)

# 3 save data -----------------------------------------------------------------

writexl::write_xlsx(data_deaths, path = paste0(path_clean, "death_by_drug.xlsx"))
writexl::write_xlsx(drugs, path = paste0(path_clean, "seized_by_drug.xlsx"))

# 4 plot data -----------------------------------------------------------------

p <- ggplot(data_deaths, aes(x = year, y = number, color = drug))+
  geom_line();p


p1 <- ggplot(drugs, aes(x = date, y = log(total), color = drug))+
  geom_line(); p1

# 5 ave plots -----------------------------------------------------------------

ggsave(paste0(path_charts, "death_by_drug.png"),p)
ggsave(paste0(path_charts, "seized_by_drug.png"),p1)


