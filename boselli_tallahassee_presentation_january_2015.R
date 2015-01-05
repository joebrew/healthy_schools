#########################################
# READ AND CLEAN NATIONAL IMMUNIZATION DATA
#########################################

### PACKAGES
library(gdata)

### SETWD
setwd("C:/Users/BrewJR/Documents/healthy_schools")

### READ IN NATIONAL IMMUNIZATION RATE DATA
national <- read.xls("national_flu_vaccine_coverage_201314.xlsx",
                     sheet = "6m-17y",
                     skip = 3,
                     stringsAsFactors = FALSE)

### CLEAN UP A BIT
# fix column names
names(national) <- c("group", "region", "area", "month",
                     "val", "ci")

#(keeping only month of december)
national <- national[which(national$month == "October"),]

# eliminate unecessary columns 
national <- national[,c("area", "val", "ci")]

# clean up val and ci
national$val <- as.numeric(as.character(national$val))
national$ci <- as.numeric(as.character(gsub("[(]|±|[)]", "", national$ci)))

# add state boolean
national$state <- vector(mode = "character",
                        length = nrow(national))
national$state <- ifelse(
  national$area %in% c("United States", "District of Columbia") | 
    grepl("Region", national$area),
  FALSE, 
  TRUE)

# sort by val
national <- national[order(national$val),]

#########################################
# PLOT EACH STATE TOGETHER
#########################################

# subset to only include states
states <- national[which(national$state),]

# assign color vector
my_colors <- colorRampPalette(c("darkorange", "blue"))(nrow(states))

bp <- barplot(states$val,
              col = my_colors,
              border = FALSE,
              names.arg = states$area,
              las = 3,
              cex.names = 0.5,
              ylim = c(0, max(states$val, na.rm = TRUE) * 1.1))

# # add line for florida
# abline(v= bp[,1][which(states$area == "Florida")],
#        lty = 2,
#        col = adjustcolor("black", alpha.f = 0.4))

# add text for rate
text(x = bp[,1],
     y = states$val,
     pos = 3,
     labels = states$val,
     cex = 0.4,
     col = adjustcolor("black", alpha.f = 0.6))

# add box
box("plot")

# add US average
us_avg <- national$val[which(national$area == "United States")]
abline(h = us_avg,
       col = adjustcolor("darkblue", alpha.f = 0.4),
       lwd = 2)

# label us average
text(x = 5,
     y = us_avg,
     pos = 3,
     labels = paste0("U.S. average: ", us_avg, "%"))

# add florida text
text(x = bp[,1][which(states$area == "Florida")],
     y = 10,
     srt = 90,
     labels = "Florida",
     col = adjustcolor("black", alpha.f = 0.7))

#########################################
# MAP EACH STATE
#########################################

# read in and clean up us map
library(maps)
us <- map("state")
us$original_names <- us$names
us$names <- sub(":.*", "", us$names)

# assign "names" column to states
states$names <- tolower(states$area)

# bring data into us map
us$val <- vector(mode = "numeric",
                 length = length(us$names))
for (i in 1:length(us$names)){
  
  a <- adist(us$names[i],
             states$names)
  # get the one with the least differences
  ind <- which.min(a)
  # get the name from std
  best_name <- states$names[ind]
  # assign val  
  us$val[i] <- states$val[which(states$names == best_name)][1]
}

# create color palette
my_colors <- colorRampPalette(c( "darkorange", "blue"))(10)

# assign color vector to us
us$temp <- vector(mode = "character",
                    length = length(us$names))
us$temp <- cut(us$val, 
    breaks = 10)

us$color <- vector(mode = "character",
                   length = length(us$names))
us$color <- my_colors[as.numeric(us$temp)]

map("state", fill = TRUE, col = us$color, border = "darkgrey")

legend(x = "bottomleft",
       fill = my_colors,
       legend = levels(us$temp),
       cex = 0.5,
       y.intersp = 1,
       ncol = 5,
       border="darkgrey",
       bty = "n",       
       title = "2013-14 pediatric immunization (October)")

# Add vals
main_polys <- which(!grepl(":", us$original_names))
map.text("state", exact = FALSE, labels = as.character(us$val), cex = 0.6,
         add = TRUE, move = FALSE, col = adjustcolor("black", alpha.f = 0.6))


#########################################
# WHAT WOULD HAPPEN IF WE WENT FROM 30 TO 40%?
#########################################
# Source weycker calculations
source("weycker.R")
# five functions:
# hospitalizations, cases, deaths, indirect_costs, direct_costs

# Function to make big numbers easier to read
millionize <- function(number){
  if(number > 1000000){
    number <- paste0(round(number / 1000000, digits = 1), " million")
  } else{
    number <- round(number, digits = 0)
  }
  return(number)  
}


# Write function to visualize different kinds of costs (takes 1 of 5 functions)
visualize <- function(fun,
                      current_imm = 29, 
                      new_imm = NULL,
                      my_colors = colorRampPalette(c("darkorange", "blue"))(100)){
  
  # Calculate values
  x <- vector(mode = "numeric", length = 100)
  for (i in 1:100){
    x[i] <- fun(i)
  }
  
  # Barplot values
  bp <- barplot(x,
                border = NA,
                col = my_colors,
                names.arg = 1:100,
                cex.names = 0.5,
                xlab = "Pediatric immunization rate") 
  
  # Label
  text(x = bp[,1][current_imm],
       y = x[current_imm]*1.1,
       labels = millionize(x[current_imm]),
       pos = 3)
  
  # new immunization
  if(!is.null(new_imm)){
    text(x = bp[,1][new_imm],
         y = x[new_imm]*1.1,
         labels = millionize(x[new_imm]),
         pos = 3,
         cex = 0.7)
    
    # difference
    text(x = bp[,1][60],
         y = max(x, na.rm = TRUE) * 0.5,
         labels = paste0("Reduction of ", millionize(x[current_imm] - x[max(new_imm)])),
         cex = 1.5)
  }
  
  box("plot")
}

# turn off scientific notation
options(scipen=999)

# Direct costs
visualize(fun = direct_costs, new_imm = 50)
title(main = "Direct costs", cex.main = 1)

#hospitalizations
visualize(fun = indirect_costs, new_imm = c(40, 50, 60, 70))
title(main = "Indirect costs", cex.main = 1)


#cases
visualize(fun = cases, new_imm = c(40, 50, 60, 70))
title(main = "Cases", cex.main = 1)

#hospitalizations
visualize(fun = hospitalizations, new_imm = c(40, 50, 60, 70))
title(main = "Hospitalizations", cex.main = 1)


#deaths
visualize(fun = deaths, new_imm = c(40, 50, 60, 70))
title(main = "Deaths", cex.main = 1)

#deaths
visualize(fun = medicaid_costs, new_imm = c(40, 50, 60, 70))
title(main = "Medicaid costs", cex.main = 1)


