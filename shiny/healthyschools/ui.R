# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Control Flu through Health Schools"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      
      
      conditionalPanel(
        condition = "input.tabs == 'Presentation'",
        p("floridahealthyschools@gmail.com"),
        tags$div(
          HTML("<a href='https://github.com/joebrew/healthy_schools'>Code for this site</a>")
        )        ),
      
      conditionalPanel(
        condition = "input.tabs == 'Mathematical projections'",

        sliderInput("current_imm", "Current immunization rate", 
                    min=0, max=100, value=30, step=1),
        
        sliderInput("new_imm", "Target immunization rate", 
                    min=0, max=100, value=40, step=1),
        
        checkboxInput("show_difference", label = "Show savings?", value = FALSE),

                    
        p("joebrew@gmail.com"),
        tags$div(
          HTML("<a href='github.com/joebrew/healthy_schools/'>Code for this site</a>")
        )
        
      ),
      
      conditionalPanel(
        condition = "input.tabs == 'Alachua-based projections'",
        
        selectInput("county", 
                    label = "Choose a county (or the entire State)",
                    choices = c("FLORIDA", "ALACHUA","BAKER","BAY","BRADFORD",
                                "BREVARD","BROWARD","CALHOUN","CHARLOTTE",
                                "CITRUS","CLAY","COLLIER","COLUMBIA",
                                "DESOTO","DIXIE","DUVAL",
                                "ESCAMBIA",
                                "FLAGLER","FRANKLIN",
                                "GADSDEN","GILCHRIST",
                                "GLADES","GULF","HAMILTON","HARDEE",
                                "HENDRY","HERNANDO","HIGHLANDS","HILLSBOROUGH",
                                "HOLMES","INDIAN RIVER","JACKSON","JEFFERSON",
                                "LAFAYETTE","LAKE","LEE","LEON","LEVY",
                                "LIBERTY","MADISON","MANATEE","MARION",
                                "MARTIN","MIAMI-DADE","MONROE","NASSAU",
                                "OKALOOSA","OKEECHOBEE","ORANGE","OSCEOLA",
                                "PALM BEACH","PASCO","PINELLAS","POLK",
                                "PUTNAM","SANTA ROSA","SARASOTA","SEMINOLE",
                                "ST. JOHNS","ST. LUCIE","SUMTER","SUWANNEE",
                                "TAYLOR","UNION","VOLUSIA",
                                "WAKULLA","WALTON","WASHINGTON"),
                    selected = "FLORIDA"),
        br(), br(),
        
        sliderInput("ed_cost", "Cost of ILI ED vist", 
                    min=0, max=10000, value=730, step=10),
        
        tags$div(
          HTML("<a href='http://www.cdc.gov/flu/spotlights/childrens-flu-costly.htm'>According to the CDC</a>, the average cost for an ILI-related ED visit is $730.")
        ),
        br(), br(),
        checkboxInput("show_alachua", "Show costs and potential savings", 
                    value = FALSE),
        helpText("Check the above box to show what would happen if the county/state achieved Alachua's pediatric immunization levels")
        
      )),
        

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(id="tabs",
                  tabPanel("Presentation",
                           h4("Both mathematical projections and real-world observation show that immunizing youth is the best way to protect the entire community from influenza outbreaks."),
                           tags$div(
                             HTML('<iframe src="https://docs.google.com/presentation/d/1JC_B_RFjfPZ1DoloUpvTdZFbmysbQ-iR_eNVDAzbmk4/embed?start=false&loop=false&delayms=60000" frameborder="0" width="960" height="749" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>')
                           )
                          # htmlOutput("motionchart1") 
                          ),
                  

                  tabPanel("Mathematical projections",
                           h4("Mathematical models predict that immunizing a high percentage of the pediatric population can protect the entire community from influenza outbreaks (Weycker et al, 2005)."),
                           
                           br(),
                           h5("Visualize the projected savings for Florida at varying immunization rates:"),
                           plotOutput("plot1"),
                           plotOutput("plot2"),
                           plotOutput("plot3"),
                           p("Weycker D, Edelsberg J, Halloran ME, et al. Population-wide benefits of routine vaccination of children against influenza. Vaccine 2005; 23(10): 1284-93.")
                           
                           
                  ),
                  
                  tabPanel("Alachua-based projections",
                           h4("As described in a recently published article (Tran et al, 2014), Alachua County's high pediatric immunization rates have lead to significant reductions in emergency room visits for influenza-like illness."),
                           br(),
                           h5("Visualize the current rate of ED visits for ILI by county, as well as the potential savings if all counties could achieve Alachua's success:"),
                           plotOutput("plot4"),
                           plotOutput("plot5"),
                           p("Cuc H. Tran, Jonathan D. Sugimoto, Juliet R. C. Pulliam, Kathleen A. Ryan, Paul D. Myers, Joan B. Castleman, Randell Doty, Jackie Johnson, Jim Stringfellow, Nadia Kovacevich, Joe Brew, Lai Ling Cheung, Brad Caron, Gloria Lipori, Christopher A. Harle, Charles Alexander, Yang Yang, Ira M. Longini, M. Elizabeth Halloran, J. Glenn Morris, Parker A. Small. School-Located Influenza Vaccination Reduces Community Risk for Influenza and Influenza-Like Illness Emergency Care Visits. PLoS ONE, 2014; 9 (12): e114479 DOI: 10.1371/journal.pone.0114479")
                           
                           
                  )
                  
                  
                
      )
    )
  )
))