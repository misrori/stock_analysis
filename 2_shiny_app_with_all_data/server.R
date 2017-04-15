library(shiny)
library(DT)
library(plotly)
library(data.table)
library(rio)
library(stringr)
library(pander)

function(input, output, session) {
  source('../my_functions.R')
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
    if(my_market()!=2){
      lista <- comp_list[comp_list$Sector==input$sector & comp_list$industry==input$industries_select & comp_list$ny==my_market() ]$Symbol
      return(lista)
    }
    else{
      lista <- comp_list[comp_list$Sector==input$sector & comp_list$industry==input$industries_select ]$Symbol
      return(lista)
    }
    
  })
  
  
  output$check_list <- renderUI({
    checkboxGroupInput("ch_list", "List of stock:",choiceNames =my_list() ,
                       choiceValues = my_list(),selected = my_list())
  })
  
  my_final_list <- reactive({
      return(input$ch_list)
  })
  
  
  my_data <- reactive({
    adatom_teljes <- adat[adat$ticker %in% my_final_list()]
    adatom_teljes$Date <- as.Date(adatom_teljes$Date)
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
  
  data_summary <- reactive({
    return(summary_adathoz(number_of_days = input$integer, my_adatom = my_data(), list_of_markets =my_list()))
  })
  output$table <- DT::renderDataTable({
    summary_adatom <-data.table(data_summary())
    summary_adatom$change <- summary_adatom$change/100
    setorder(summary_adatom,-change)
    DT::datatable(summary_adatom,extensions = c('Buttons','FixedHeader'),class = 'cell-border stripe',rownames = FALSE,
                  filter = 'top', options = list(dom = 'Blfrtip', fixedHeader = TRUE,pageLength = 100,lengthMenu = c(10,50,500 ),
                                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                                                 columnDefs = list())) %>% 
      formatCurrency('Close', "$") %>%
      formatPercentage('change', 0) %>%
      formatRound('Close', digits = 0)
                  })
  
  
  output$nrow <- renderText({ paste('There are', nrow(data_summary()), 'stocks matched for the conditions', sep= ' ') })
  output$average <- renderText({ paste('The averege yield of the stocks:', mean(data_summary()$change), sep= ' ') })
  output$numbers <- renderText({ paste('There are', sum(ifelse(data_summary()$change>0,1,0)), 'stocks with positiv yields and',
                                       sum(ifelse(data_summary()$change<0,1,0)), 'with negativ yilds', sep= ' ') })
}
