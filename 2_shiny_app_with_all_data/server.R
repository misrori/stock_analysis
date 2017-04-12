library(shiny)
library(DT)
library(plotly)
library(data.table)
library(rio)
library(stringr)


function(input, output, session) {
  source('my_functions.R')
  comp_list <- data.table(import('../0_step_get_the_data/comp_list.RData'))
  adat <- data.table(import('../0_step_get_the_data/Stock_data.RData'))
  adat$Close <- as.numeric(adat$Close)
  
  my_industries <- reactive({
    indristies <- c("",comp_list[comp_list$Sector==input$sector,]$industry)
    return(indristies)
  })
  

  
  output$industries <- renderUI({
    selectInput("industries_select", "Vállasz industries",selected = "", choices= my_industries() )
  })
  
  my_market <- reactive({
    return(input$rb)
  })
  my_list <- reactive({
    lista <- comp_list[comp_list$Sector==input$sector & comp_list$industry==input$industries_select ]$Symbol
    return(lista)
  })
  

  
  
  
  my_data <- reactive({
    if(my_market()=='2'){
      adatom_teljes <- adat[adat$ticker %in% my_list()]
      adatom_teljes$Date <- as.Date(adatom_teljes$Date)
    }
    else{
      adatom_teljes <- adat[adat$ticker %in% my_list()& adat$ny==my_market(),]
      
      adatom_teljes$Date <- as.Date(adatom_teljes$Date)
    }
    
    return(adatom_teljes)
  })
  

  my_plot <- reactive({
    if(nrow(my_data())!=0){
    return(tozsde_plot(number_of_days = input$integer, my_adatom = my_data(), list_of_markets =my_list()))
    }
    else{
      return(plot_ly(x=0,y=0,mode="markers",type="scatter"))
    }
  })
  
  output$summary_plot <- renderPlotly({
    my_plot()
  })
  
}
