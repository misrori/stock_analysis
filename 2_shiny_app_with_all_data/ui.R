library(shiny)
library(plotly)
library(DT)
library(data.table)
library(rio)


navbarPage(
           title="Stock Analysis",

           tabPanel("Plots",
                    sidebarLayout(
                      sidebarPanel(
                        
                        selectInput("sector", label = "Chosse a Sector", 
                                    choices = c("","Basic industries"="basic_industries", 
                                                "Capital Goods"= "capital_goods", "Consumer Durables"= "consumer_durables", 
                                                "Consumer Non-Durables" = "consumer_non-durables", 
                                                "Consumer Services"= "consumer_services","Energy" = "energy",
                                                "Finance" ="finance", "Healt Care"= "health_care", 
                                                "Miscellaneous"="miscellaneous","Public Utilities"= "public_utilities", 
                                                "Technology"="technology", "Transportation"="transportation"), 
                                    selected = "Technology"),
                        uiOutput("industries"),
                        sliderInput("integer", "Number of days before:", min=0, max=300, value=50),
                        radioButtons('rb', 'Select markets', choices = c('NYSE'=1, 'NASDAQ'=0, 'BOTH'=2), selected = NULL),
                        uiOutput("check_list")
         
                        
                      ),
                      mainPanel(
                        plotlyOutput('summary_plot')
                      )
                    )
                    
           ),
           tabPanel("Summary",
                    h1("Summary of the selected conditons", align = "center"),
                    verbatimTextOutput("nrow"),
                    br(),
                    verbatimTextOutput("average"),
                    br(),
                    verbatimTextOutput("numbers"),
                    br(),
                    dataTableOutput("table"),
                    # h2("Magyarország ", round(sum(adat$osszeg)/1000, 2), "milliárd forintot fizetett ki", align="center"),
                    # h2( nrow(adat), "nyertes pályázatra" ,align="center"),
                    # h2( 'a Széchenyi 2020 program keretében!',align="center"),
                    # br(),
                    # br(),
                    tags$div(
                      h3('Az adatok forrása',align="center"), 
                      HTML(' <center> <a target="_blank", href="https://finance.yahoo.com/">Yahoo Finance</a> </center>')
                    ),
                    br(),
                    h3('Az adatok utolsó frissítési dátuma', align="center"),
                    h4('2017-03-07', align="center"),
                    br(),
                    tags$div(
                      h3('Az oldalt készítette',align="center"), 
                      HTML(' <center> <a target="_blank", href="http://www.orsosmihaly.com">Orsós Mihály</a> </center>')
                    )
           ),

           tags$head(
             tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
           )# http://bootswatch.com/#Grafikon_tab
           
           
           
           )#nav
