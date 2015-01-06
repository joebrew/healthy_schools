# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(googleVis)
#setwd("C:/Users/BrewJR/Documents/healthy_schools/shiny/healthyschools")
source("boselli_tallahassee_presentation_january_2015.R")



shinyServer(function(input, output) {
  
  output$plot1 <- renderPlot({

    par(mfrow = c(1,2))
    par(mar = c(6,2, 1, 1))
    # Direct costs
    visualize(fun = direct_costs, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Direct costs", cex.main = 1.5)
    
    #medicaid costs
    visualize(fun = medicaid_costs, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Medicaid costs", cex.main = 1.5)
    
    par(mfrow = c(1,1))
  })
  
  output$plot2 <- renderPlot({
    
    par(mfrow = c(1,2))
    par(mar = c(6,2, 1, 1))
    
    #cases
    visualize(fun = cases, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Cases", cex.main = 1.5)
    
    #hospitalizations
    visualize(fun = hospitalizations, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Hospitalizations", cex.main = 1.5)
    
    
    par(mfrow = c(1,1))
  })
  
  output$plot3 <- renderPlot({
    
    par(mfrow = c(1,2))
    par(mar = c(6,2, 1, 1))
    
    
    #deaths
    visualize(fun = deaths, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Deaths", cex.main = 1.5)
    

    #indirect costs
    visualize(fun = indirect_costs, new_imm = input$new_imm, current_imm = input$current_imm,
              show_difference = input$show_difference)
    title(main = "Indirect costs", cex.main = 1.5)
    
    
    par(mfrow = c(1,1))
  })


#   
#   output$motionchart1 <- renderGvis({
#     
#     gvisMotionChart(data = WorldBank,
#                     idvar="country", timevar="year",
#                     xvar="life.expectancy", 
#                     yvar="fertility.rate",
#                     colorvar="region", 
#                     sizevar="population",
#                     options=list(width=550, height=500))
#     
#   })
  
})