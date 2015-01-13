#########################################
# READ AND CLEAN NATIONAL IMMUNIZATION DATA
#########################################

# Load once and save for shiny app
load("shiny_data.RData")
# 
# ### PACKAGES
# library(gdata)
# 
# ### SETWD
# setwd("C:/Users/BrewJR/Documents/healthy_schools/shiny/healthyschools")
# 
# ### READ IN NATIONAL IMMUNIZATION RATE DATA
# national <- read.xls("national_flu_vaccine_coverage_201314.xlsx",
#                      sheet = "6m-17y",
#                      skip = 3,
#                      stringsAsFactors = FALSE)
# 
# ### CLEAN UP A BIT
# # fix column names
# names(national) <- c("group", "region", "area", "month",
#                      "val", "ci")
# 
# #(keeping only month of december)
# national <- national[which(national$month == "October"),]
# 
# # eliminate unecessary columns 
# national <- national[,c("area", "val", "ci")]
# 
# # clean up val and ci
# national$val <- as.numeric(as.character(national$val))
# national$ci <- as.numeric(as.character(gsub("[(]|±|[)]", "", national$ci)))
# 
# # add state boolean
# national$state <- vector(mode = "character",
#                         length = nrow(national))
# national$state <- ifelse(
#   national$area %in% c("United States", "District of Columbia") | 
#     grepl("Region", national$area),
#   FALSE, 
#   TRUE)
# 
# # sort by val
# national <- national[order(national$val),]
# 
# #########################################
# # PLOT EACH STATE TOGETHER
# #########################################
# 
# # subset to only include states
# states <- national[which(national$state),]
# 
# # assign color vector
# my_colors <- colorRampPalette(c("darkorange", "blue"))(nrow(states))
# 
# bp <- barplot(states$val,
#               col = my_colors,
#               border = FALSE,
#               names.arg = states$area,
#               las = 3,
#               cex.names = 0.5,
#               ylim = c(0, max(states$val, na.rm = TRUE) * 1.1))
# 
# # # add line for florida
# # abline(v= bp[,1][which(states$area == "Florida")],
# #        lty = 2,
# #        col = adjustcolor("black", alpha.f = 0.4))
# 
# # add text for rate
# text(x = bp[,1],
#      y = states$val,
#      pos = 3,
#      labels = states$val,
#      cex = 0.4,
#      col = adjustcolor("black", alpha.f = 0.6))
# 
# # add box
# box("plot")
# 
# # add US average
# us_avg <- national$val[which(national$area == "United States")]
# abline(h = us_avg,
#        col = adjustcolor("darkblue", alpha.f = 0.4),
#        lwd = 2)
# 
# # label us average
# text(x = 5,
#      y = us_avg,
#      pos = 3,
#      labels = paste0("U.S. average: ", us_avg, "%"))
# 
# # add florida text
# text(x = bp[,1][which(states$area == "Florida")],
#      y = 10,
#      srt = 90,
#      labels = "Florida",
#      col = adjustcolor("black", alpha.f = 0.7))
# 
# #########################################
# # MAP EACH STATE
# #########################################
# 
# # read in and clean up us map
# library(maps)
# us <- map("state")
# us$original_names <- us$names
# us$names <- sub(":.*", "", us$names)
# 
# # assign "names" column to states
# states$names <- tolower(states$area)
# 
# # bring data into us map
# us$val <- vector(mode = "numeric",
#                  length = length(us$names))
# for (i in 1:length(us$names)){
#   
#   a <- adist(us$names[i],
#              states$names)
#   # get the one with the least differences
#   ind <- which.min(a)
#   # get the name from std
#   best_name <- states$names[ind]
#   # assign val  
#   us$val[i] <- states$val[which(states$names == best_name)][1]
# }
# 
# # create color palette
# my_colors <- colorRampPalette(c( "darkorange", "blue"))(10)
# 
# # assign color vector to us
# us$temp <- vector(mode = "character",
#                     length = length(us$names))
# us$temp <- cut(us$val, 
#     breaks = 10)
# 
# us$color <- vector(mode = "character",
#                    length = length(us$names))
# us$color <- my_colors[as.numeric(us$temp)]
# 
# map("state", fill = TRUE, col = us$color, border = "darkgrey")
# 
# legend(x = "bottomleft",
#        fill = my_colors,
#        legend = levels(us$temp),
#        cex = 0.5,
#        y.intersp = 1,
#        ncol = 5,
#        border="darkgrey",
#        bty = "n",       
#        title = "2013-14 pediatric immunization (October)")
# 
# # Add vals
# main_polys <- which(!grepl(":", us$original_names))
# map.text("state", exact = FALSE, labels = as.character(us$val), cex = 0.6,
#          add = TRUE, move = FALSE, col = adjustcolor("black", alpha.f = 0.6))
# 
# 
# #########################################
# # WHAT WOULD HAPPEN IF WE WENT FROM 30 TO 40%?
# #########################################
# # Source weycker calculations
# source("weycker.R")
# # five functions:
# # hospitalizations, cases, deaths, indirect_costs, direct_costs
# 
# # Function to make big numbers easier to read
# millionize <- function(number){
#   if(number > 1000000 | number < -1000000){
#     number <- paste0(round(number / 1000000, digits = 1), " million")
#   } else{
#     number <- round(number, digits = 0)
#   }
#   return(number)  
# }
# 
# 
# # Write function to visualize different kinds of costs (takes 1 of 5 functions)
# visualize <- function(fun,
#                       current_imm = 29, 
#                       new_imm = NULL,
#                       my_colors = colorRampPalette(c("darkorange", "blue"))(100),
#                       show_difference = FALSE){
#   
#   # Calculate values
#   x <- vector(mode = "numeric", length = 100)
#   for (i in 1:100){
#     x[i] <- fun(i)
#   }
#   
#   # Barplot values
#   bp <- barplot(x,
#                 border = NA,
#                 col = my_colors,
#                 #names.arg = 1:100,
#                 cex.names = 0.5,
#                 xlab = NA, #"Pediatric immunization rate",
#                 space = 0) 
#   mtext(text = seq(0, 100, 10),
#         side = 1, 
#         line =0,
#         at = seq(0, 100, 10))
#   mtext(text = "Pediatric immunization rate",
#         side = 1,
#         line = 1,
#         at = 50)
#   
#   # Label
#   text(x = bp[,1][current_imm],
#        y = x[current_imm]*1.1,
#        labels = millionize(x[current_imm]),
#        pos = 4,
#        col = adjustcolor("darkorange", alpha.f = 0.8),
#        cex = 0.6)
#   points(x = bp[,1][current_imm],
#        y = x[current_imm], pch = 16,
#        col = adjustcolor("darkorange", alpha.f = 0.8))
#   
#   # ablines
#   abline(v = bp[,1][current_imm], col = adjustcolor("darkorange", alpha.f = 0.1), lwd = 2)
#   abline(v = bp[,1][new_imm], col = adjustcolor("blue", alpha.f = 0.1), lwd = 2)
#   
#   
#   # new immunization
#   if(!is.null(new_imm)){
#     text(x = bp[,1][new_imm],
#          y = x[new_imm]*1.1,
#          labels = millionize(x[new_imm]),
#          pos = 4,
#          cex = 0.6,
#          col = adjustcolor("blue", alpha.f = 0.7))
#     points(x = bp[,1][new_imm],
#            y = x[new_imm], pch = 16,
#            col = adjustcolor("blue", alpha.f = 0.7))
#     
#     
#     # difference
#     if(show_difference){
#       text(x = bp[,1][70],
#            y = max(x, na.rm = TRUE) * 0.75,
#            labels = paste0("Reduction of ", millionize(x[current_imm] - x[max(new_imm)])),
#            cex = 1.2,
#            col = adjustcolor("black", alpha.f = 0.6))
#     }
# 
#   }
#   
#   box("plot")
# }
# 
# # turn off scientific notation
# options(scipen=999)
# 
# # Direct costs
# visualize(fun = direct_costs, new_imm = c(40, 50, 60, 70))
# title(main = "Direct costs", cex.main = 1)
# 
# #indirect costs
# visualize(fun = indirect_costs, new_imm = c(40, 50, 60, 70))
# title(main = "Indirect costs", cex.main = 1)
# 
# 
# #cases
# visualize(fun = cases, new_imm = c(40, 50, 60, 70))
# title(main = "Cases", cex.main = 1)
# 
# #hospitalizations
# visualize(fun = hospitalizations, new_imm = c(40, 50, 60, 70))
# title(main = "Hospitalizations", cex.main = 1)
# 
# 
# #deaths
# visualize(fun = deaths, new_imm = c(40, 50, 60, 70))
# title(main = "Deaths", cex.main = 1)
# 
# #medicaid_costs
# visualize(fun = medicaid_costs, new_imm = c(40, 50, 60, 70))
# title(main = "Medicaid costs", cex.main = 1)
# 
# 
# # average
# avg <- 35.4
# cases(30) - cases(36)
# hospitalizations(30) - hospitalizations(36)
# deaths(30) - deaths(36)
# direct_costs(30) - direct_costs(36)
# indirect_costs(30) - indirect_costs(36)
# medicaid_costs(30) - medicaid_costs(36)
# 
# #################################
# # ER DATA
# #################################
# 
# # CENSUS STUFF
# source("census.R")
# 
# # "state" has the age breakdown for each county
# # add some grouped names to ages
# state$age0004 <-NA
# state$age0517 <-NA
# state$age1844 <-NA
# state$age4564 <-NA
# state$age65plus<-NA
# 
# for (i in 1:nrow(state)){
#   state$age0004[i] <- sum(state[i,2:6])
#   state$age0517[i] <-sum(state[i,7:19])
#   state$age1844[i] <-sum(state[i,19:46])
#   state$age4564[i] <-sum(state[i,46:66])
#   state$age65plus[i] <-sum(state[i,67:104])
# }
# 
# 
# # clean up
# place <- state$AreaName
# state <- data.frame(state[,c("age0004", "age0517", "age1844", "age4564", "age65plus")])
# state <- cbind(state, place)
# # # reads in a df called "ages" with florida's age breakdown
# # 
# # # add some grouped names to ages
# # ages$age0004 <- sum(ages[,1:5])
# # ages$age0517 <-sum(ages[,6:18])
# # ages$age1844 <-sum(ages[,18:45])
# # ages$age4564 <-sum(ages[,45:65])
# # ages$age65plus<-sum(ages[,66:104])
# # 
# # # clean up
# # ages <- data.frame(ages[,c("age0004", "age0517", "age1844", "age4564", "age65plus")])
# # ages$place <- "florida"
# # 
# # # add some grouped names to alachua
# # alachua$age0004 <- sum(alachua[,1:5])
# # alachua$age0517 <-sum(alachua[,6:18])
# # alachua$age1844 <-sum(alachua[,18:45])
# # alachua$age4564 <-sum(alachua[,45:65])
# # alachua$age65plus<-sum(alachua[,66:104])
# # 
# # # clean up
# # alachua <- data.frame(alachua[,c("age0004", "age0517", "age1844", "age4564", "age65plus")])
# # alachua$place <- "alachua"
# # 
# # # combine
# # er <- rbind(alachua, ages)
# # # based on 2012/13 year
# 
# 
# # Read in attack rates for 11/12 year and 12/13 year
# cucIndirectProtection1112 <-  read.csv("cuc_data/cucIndirectProtection1112.csv")
# cucIndirectProtection1213 <- read.csv("cuc_data/cucIndirectProtection1213.csv")
# flu12 <- cucIndirectProtection1112
# flu13 <- cucIndirectProtection1213
# 
# # get mean for 11/12 and 12/13 years
# flu <- flu12[,-1] + flu13[,-1]
# flu$place <- flu12$place
# 
# # remove unecessary columns
# flu <- flu[which(!grepl("high|low|region", flu$place)),]
# 
# # I've now got two dataframes:
# # flu: ili attack rates (per 100,000)
# # er: number of people in each age group
# 
# # convert flu to p
# flu[,1:5] <- flu[,1:5] / 100000
# 
# # clean up place
# flu$place <- toupper(flu$place)
# 
# # Calculate number of true cases 
# real <- state
# for (i in 1:nrow(state)){
#   real[i, -6] <- real[i, -6] * flu[2, -6]
# }
# # if alachua were like florida
# worst <- real
# # Fix alachua
# # real[which(real$place == "ALACHUA"), -6] <- 
# #   state[which(state$place == "ALACHUA"), -6] * flu[1, -6]
# 
# # Calculate number of cases if all counties like alachua
# best <- state
# for (i in 1:nrow(state)){
#   best[i, -6] <- best[i, -6] * flu[1, -6]
# }
# 
# 
# 
# 
# 
# # # # Calculate number of true cases 
# # # real <- flu[,-6] * er[, -6]
# # 
# # # Calculate number of cases if all counties like alachua
# # best <- real
# # best[2,-6] <- er[2,-6] * flu[1,-6]
# # 
# # # Calculate number of cases if alachua like florida
# # worst <- real
# # worst[1, -6] <- er[1, -6] * flu[2, -6]
# 
# # Function to plot
# plot_scenario <- function(df, 
#                           county = "FLORIDA", 
#                           #alachua_row=TRUE, 
#                           add = FALSE, 
#                           color = "blue"){
#   #number <- ifelse(alachua_row, 1, 2)
# 
#   vals <- as.numeric(df[which(df$place == county),1:5])
#   bad_vals  <- as.numeric(worst[which(worst$place == county),1:5])
#   
#   if(add){
#     bp <- barplot(vals,
#                   add = add, 
#                   col = adjustcolor(color, alpha.f = 0.6))
#     
#     
#     text(x = bp[,1],
#          y = round(vals),
#          labels = round(vals),
#          pos = 1,
#          col = adjustcolor("black", alpha.f = 0.8))
#     
#     text(x = bp[5,1],
#          y = max(vals) * 1.2,
#          pos = 3,
#          col = adjustcolor("black", alpha.f = 0.8),
#          labels = paste0(millionize( (sum(bad_vals) - sum(vals) )  ), "\nED cases\naverted"),
#          cex = 1.7)
#     
# #     legend(x = "topright",
# #            fill = adjustcolor(c("blue", "purple"), alpha.f = 0.6),
# #            bty = "n",
# #            legend = c("True", "Projected"),
# #            cex = 0.6)
# 
# 
#   }else{
#     bp <- barplot(vals,
#                   add = FALSE, 
#                   names.arg = c("0-4",
#                                 "5-17", 
#                                 "18-44",
#                                 "45-64",
#                                 "65 plus"),
#                   xlab = "Age group",
#                   ylab = "ED visits",
#                   ylim = c(0, max(vals) * 1.1),
#                   col = adjustcolor(color, alpha.f = 0.4)) 
#     
#     text(x = bp[,1],
#          y = round(vals),
#          labels = round(vals),
#          pos = 3,
#          col = color)
#   }
# 
#   box("plot")
# 
# }
# 
# plot_scenario(df = worst, county = "ALACHUA")
# plot_scenario(df = best, county = "ALACHUA", col = "red", add = T)
# 
# 
# plot_scenario(df = worst, county = "FLORIDA")
# plot_scenario(df = best, county = "FLORIDA", col = "red", add = T)
# 
# plot_scenario(df = worst, col = "red")
# plot_scenario(df = real, add = T, col = "blue")
# legend(x = "topright",
#        fill = adjustcolor(c("red", "blue"), alpha.f = 0.5),
#        legend = c("Expected", "Observed"))
# 
# plot_scenario(df = real, alachua_row = FALSE, col = "red")
# plot_scenario(df = best, alachua_row = FALSE, col = "blue", add = TRUE)
# legend(x = "topright",
#        fill = adjustcolor(c("red", "blue"), alpha.f = 0.5),
#        legend = c("Observed", "Alachua's rates"))
# 
# 
# # What florida could do
# vals <- as.numeric((real - best)[2,])
# bp <- barplot(vals,
#               names.arg = c("0-4",
#                             "5-17", 
#                             "18-44",
#                             "45-64",
#                             "65 plus"),
#               xlab = "Age group",
#               ylab = "ED visits",
#               ylim = c(0, max(vals) * 1.1),
#               col = adjustcolor("blue", alpha.f = 0.4)) 
# 
# 
# text(x = bp[,1],
#      y = round(vals),
#      labels = round(vals),
#      pos = 3,
#      col = "blue")
# box("plot")
# 
# 
# 
# # source the ed_savings function
# source("ed_savings.R")
# # Load once and save for shiny app
# save.image("shiny_data.RData")

# # MAP FOR TONY
# library(maps)
# my_map <- map("county", "florida")
# my_map$names <- sub("florida,", "", my_map$names)
# my_map$names[which(grepl("okaloosa", my_map$names))] <- "okaloosa"
# 
# county <- data.frame("county" = my_map$names)
# healthy_schools <- c("escambia", "santa rosa", "okaloosa",
#                      "lafayette", "suwannee", "hamilton", "columbia",
#                      "baker", "nassau", "duval", "clay", "putnam", "union", "bradford",
#                      "st johns", "flagler", "marion", "volusia", "hernando", 
#                      "pasco", "hillsborough", "polk", "osceola", "seminole",
#                      "st lucie", "sarasota", "palm beach", "miami-dade",
#                      "okaloosa")
# county$tony <- NA
# county$tony <-  county$county %in% healthy_schools
# county$color <- adjustcolor(ifelse(county$tony, "darkred", "grey"), alpha.f = 0.5)
# map("county", "fl",
#     fill = TRUE, 
#     col = county$color)
# map.text("county", "fl", exact = FALSE, labels = toupper(as.character(county$county)), cex = 0.1,
#          add = TRUE, move = FALSE, col = adjustcolor("black", alpha.f = 0.6))
# legend("left",
#        fill = adjustcolor(c("darkred", "grey"), alpha.f = 0.5),
#        legend = c("Yes", "No"),
#        title = "Healthy Schools Presence",
#        bty = "n")
