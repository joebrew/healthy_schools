### SETWD
#setwd("C:/Users/BrewJR/Documents/healthy_schools")

library(dplyr)

## Read in population data for florida zip codes
pop <- read.csv("florida_details.csv", skip = 1)
names(pop) <- gsub("[.]", "", names(pop))
pop <- tbl_df(pop)

# Get the age distribution for Alachua County
ages <- pop %>% 
  filter(RaceEthnicity == "Total" &
           AreaName == "Florida") %>%
  select(TotalUnder1Year:Total110YearsandOlder)
names(ages)[c(1:2, 
           101:103)] <- c("Total0Years", "Total1Years",
                          "Total100-104Years", "Total105-109Years", "Total110+Years")

alachua <- pop %>% 
  filter(RaceEthnicity == "Total" &
           AreaName == "Alachua County") %>%
  select(TotalUnder1Year:Total110YearsandOlder)
names(alachua)[c(1:2, 
           101:103)] <- c("Total0Years", "Total1Years",
                          "Total100-104Years", "Total105-109Years", "Total110+Years")

pop$AreaName <- as.character(toupper(sub(" County", "", pop$AreaName)))
state <- pop %>% 
  filter(RaceEthnicity == "Total" ) %>%
  select(AreaName, TotalUnder1Year:Total110YearsandOlder)
names(state)[c(2:3, 
                 102:104)] <- c("Total0Years", "Total1Years",
                                "Total100-104Years", "Total105-109Years", "Total110+Years")
