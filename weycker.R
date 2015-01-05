
#load in packages
library(maps)
library(classInt)
library(RCurl)
library(xtable)
library(RColorBrewer)
library(dplyr)
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

##############################
#TWO STEPS TO MODELLING
#1. CREATE THE GENERIC MATHEMATICAL/ALGEBRAIC MODEL 
#2. APPLY IT TO THE STATE (AND TO ALACHUA) AT DIFFERING LEVELS
##############################

# ##############################
# ### Read in 2013/14 free lunch data
# ##############################
# 
# # Read in frLunch once from google
# # myLink <- "https://docs.google.com/spreadsheets/d/1-o_HtdEK9ppCT5eU0YteKW2D7imtNgJY601y8LcozUc/export?gid=1752249144&format=csv"
# # library(classInt)
# # library(RCurl)
# # library(maps)
# # library(xtable)
# # library(RColorBrewer)
# # options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
# # myCsv <- getURL(myLink)
# # frLunch <- read.csv(textConnection(myCsv), skip=0)
# # #Make numeric columns into numeric R objects
# # frLunch$free <- as.numeric(gsub(",|#" ,"", frLunch$free))
# # frLunch$totMem <- as.numeric(gsub(",|#" ,"", frLunch$totMem))
# # frLunch$reduced <- as.numeric(gsub(",|#" ,"", frLunch$reduced))
# # # Save it
# # write.csv(frLunch, "C:/Users/BrewJR/Documents/ShinyApps/sliv/frLunch.csv")
# # Read it
# #frLunch <- read.csv("frLunch.csv")
# frLunch <- read.csv("C:/Users/BrewJR/Documents/ShinyApps/sliv/frLunch.csv")
# 
# ##############################
# ### makes dfSchool and ADD APPROPRIATE COLUMNS
# ##############################
# dfSchool <- frLunch[,c("district", "id", "School", "totMem", "free",
#                        "reduced", "frper")]
# dfSchool$frper <- as.numeric(as.character(dfSchool$frper))
# 
# dfSchool$district <- as.character(dfSchool$district)
# #We want to use frPer as a PROXY indicator for the percentage of 
# #students who are going to receive the VFC vaccine for each county
# #frPer for Alachua = 49.026091
# #vfcPer for Alachua = 41.78791  5773 / (5773+8042) * 100
# # 41.78791 / 49.026091  = 0.8523606
# #Therefore, dfCounty$vfcPer (our estimate) = 0.8523606*dfCounty$frPer
# ##############################
# ### Make vfcPer
# ##############################
# dfSchool$vfcPer <- 0.8523606*dfSchool$frper
# # 
# # 

####################################
# WEYCKER REDUCTIONS
####################################
#### READ IN WEYCKER DATA
myLink2 <- "https://docs.google.com/spreadsheets/d/1Hun4-6-5oKeWcfFjEMkueb75_AWc3lcV9DBIX60K3wM/export?gid=0&format=csv"
myLink3 <- "https://docs.google.com/spreadsheets/d/12Iv72owJCLEb3bH2djOaQDMXmVZSOIWURLAIZOcbzN4/export?gid=0&format=csv"

#WEYCKER DATA
myCsv <- getURL(myLink2)
weycker <- read.csv(textConnection(myCsv), skip=0)

#FLORIDA POPULATION DATA
myCsv <- getURL(myLink3)
fl <- read.csv(textConnection(myCsv), skip=0)

#CLEAN UP fl
fl$pop <- as.numeric(as.character(gsub(",","", fl$pop)))
fl$county <- toupper(fl$county)

#CALCULATE PER COLUMNS FOR REDUCTIONS
weycker$casesPer <- weycker$cases/ weycker$cases[1]
weycker$hospitalizationsPer <- weycker$hospitalizations/ weycker$hospitalizations[1]
weycker$deathsPer <- weycker$deaths/ weycker$deaths[1]
weycker$directCostsPer <- weycker$directCosts/ weycker$directCosts[1]
weycker$indirectCostsPer <- weycker$indirectCosts/ weycker$indirectCosts[1]

weycker$unImmRate <- 100-weycker$immRate

# CALCULATE THE RELATIONSHIP BETWEEN IMMRATE AND REDUCTIONS
immTable <- as.data.frame(1:105)
colnames(immTable) <- "immRate"

immTable$immRateSliv <- c(0,0,0,0,0,1:100)

#cases
casesTemp <- approx(x = weycker$immRate, y = weycker$casesPer, n=105)
immTable$cases <- casesTemp$y

#hospitalizations
hospitalizationsTemp <- approx(x = weycker$immRate, y = weycker$hospitalizationsPer, n=105)
immTable$hospitalizations <- hospitalizationsTemp$y

#deaths
deathsTemp <- approx(x = weycker$immRate, y = weycker$deathsPer, n=105)
immTable$deaths <- deathsTemp$y

#directCosts
directCostsTemp <- approx(x = weycker$immRate, y = weycker$directCostsPer, n=105)
immTable$directCosts <- directCostsTemp$y

#indirectCosts
indirectCostsTemp <- approx(x = weycker$immRate, y = weycker$indirectCostsPer, n=105)
immTable$indirectCosts <- indirectCostsTemp$y

#indirectCosts
immTable$medicaidCosts <- immTable$directCosts * 0.5


#CALCULATE CURRENT ESTIMATED BURDEN OF FLU

#florida's population as % of us
flPerPop <- 19.32 / 313.9
#population increase since Weycker artilce
popIncrease <- 317/295
#inflation since Weycker article
inflation <- 1.36

#add a per column to fl
fl$per <- fl$pop / sum(fl$pop)

#CASES
fl$cases <- fl$per * flPerPop*popIncrease*weycker$cases[which(weycker$immRate == 0)] * 1000 #weycker = cases in thousands

#hospitalizations
fl$hospitalizations <- fl$per * flPerPop * popIncrease * weycker$hospitalizations[which(weycker$immRate == 0)]

#deaths
fl$deaths <- fl$per * flPerPop * popIncrease * weycker$deaths[which(weycker$immRate == 0)]

#indirectCosts
fl$indirectCosts <- fl$per * flPerPop * popIncrease * inflation * 
  weycker$indirectCosts[which(weycker$immRate == 0)] * 1000000

#directCosts
fl$directCosts <- fl$per * flPerPop * popIncrease * inflation * 
  weycker$directCosts[which(weycker$immRate == 0)] * 1000000

# medicaidCosts (half of direct costs)
fl$medicaidCosts <- fl$directCosts * 0.5

########### WRITE FUNCTIONS TO CALCLUATE VARIOUS SAVINGS AT VARIOUS IMMUNIZATION RATES

#cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cases <- function(imm){
    sum(fl$cases * 
       immTable$cases[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}
cases(30)

#hospitalizations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hospitalizations <- function(imm){
  sum(fl$hospitalizations * 
        immTable$hospitalizations[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}
hospitalizations(33)

# deaths
#deaths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deaths <- function(imm){
  sum(fl$deaths * 
        immTable$deaths[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}
deaths(30)

# indirectCosts
#indirectCosts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indirect_costs <- function(imm){
  sum(fl$indirectCosts * 
        immTable$indirectCosts[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}

# directCosts
#cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
direct_costs <- function(imm){
  sum(fl$directCosts * 
        immTable$directCosts[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}

# medicaidCosts
#cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
medicaid_costs <- function(imm){
  sum(fl$medicaidCosts * 
        immTable$medicaidCosts[which(immTable$immRateSliv == imm)][1], na.rm = TRUE)
}

