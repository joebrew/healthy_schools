ed_savings <- function(df = real, 
                       county = "FLORIDA", 
                       alachua_row=TRUE, 
                       add = FALSE, 
                       color = "blue",
                       ed_cost = 2133,
                       show_alachua = FALSE){
  number <- ifelse(alachua_row, 1, 2)
  
  vals <- as.numeric(df[which(df$place == county),1:5])    
  visits <- sum(vals)
  cost <- visits * ed_cost
  
  best_vals <- as.numeric(best[which(best$place == county),1:5])
  best_visits <- sum(best_vals)
  best_cost <- best_visits * ed_cost
  
  if(!show_alachua){
    
    bp <- barplot(1:10, col = "white", border = "white", yaxt = "n")
#     bp <- barplot(cost,
#                   names.arg = "Current costs",
#                   ylab = "Dollars")
#     text(x = bp[,1],
#          y = cost,
#          pos = 1,
#          labels = millionize(cost))
  } else{
    bp <- barplot(c(cost, best_cost),
                  names.arg = c("Current costs", "Projected costs"),
                  ylab = "Dollars",
                  col = adjustcolor(c("darkorange", "blue"), alpha.f = 0.6),
                  ylim = c(0, cost * 1.1))
    text(x = bp[,1],
         y = c(cost, best_cost),
         pos = 1,
         labels = c(millionize(cost), millionize(best_cost)))
    
    text(x = bp[2,1],
         y = cost * 0.7,
         labels = paste0("Savings of:\n", millionize(cost - best_cost), " dollars"),
         cex = 2)
    title(main = "Savings in avoided ILI ED visits")
    box("plot")
    
    
  }
  
  
}
