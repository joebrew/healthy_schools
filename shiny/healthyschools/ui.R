# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Healthy Schools for Florida"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      
      
      conditionalPanel(
        condition = "input.tabs == 'Presentation'",
        p("floridahealthyschools@gmail.com"),
        tags$div(
          HTML("<a href='github.com/joebrew/healthy_schools/'>Code for this site</a>")
        )        ),
      
      conditionalPanel(
        condition = "input.tabs == 'Explore the data'",

        sliderInput("current_imm", "Current immunization rate", 
                    min=0, max=100, value=30, step=1),
        
        sliderInput("new_imm", "Target immunization rate", 
                    min=0, max=100, value=40, step=1),
        
        checkboxInput("show_difference", label = "Show savings?", value = TRUE),

                    
        p("joebrew@gmail.com"),
        tags$div(
          HTML("<a href='github.com/joebrew/healthy_schools/'>Code for this site</a>")
        )
        
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(id="tabs",
                  tabPanel("Presentation",
                           tags$div(
                             HTML('<iframe src="https://docs.google.com/presentation/d/1JC_B_RFjfPZ1DoloUpvTdZFbmysbQ-iR_eNVDAzbmk4/embed?start=false&loop=false&delayms=60000" frameborder="0" width="480" height="389" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>')
                           )
                          # htmlOutput("motionchart1") 
                          ),
                  

                  tabPanel("Explore the data",
                           p("These data come from the Human Mortality Database, but the visualizations are original."),
                           plotOutput("plot1"),
                           plotOutput("plot2"),
                           plotOutput("plot3")
                           
                  )
      )
    )
  )
))