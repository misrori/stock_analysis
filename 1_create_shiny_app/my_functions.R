library(stringr)
prices <- function( tickers  ,startDate=c("01", "01", "1900") ){
  ### define the URLs
 
  my_month <- ifelse(data.table::month(Sys.Date())-1<10,paste('0', data.table::month(Sys.Date())-1, sep=''), data.table::month(Sys.Date())-1)
  my_day <-str_split(as.character(Sys.Date()), '-')[[1]][3]
  my_year <- str_split(as.character(Sys.Date()), '-')[[1]][1]
  
  addstock_datas <- paste("http://real-chart.finance.yahoo.com/table.csv?s=",
                          tickers, "&a=", startDate[1], "&b=", startDate[2], "&c=", startDate[3],
                          "&d=", as.character(my_month), "&e=",as.character(my_day), "&f=",as.character(my_year),
                          "&g=d&ignore=.csv", sep="");
  
  ## using lapply instead of a loop: faster
  df <- lapply(seq(addstock_datas), function(x){temp <- read.csv(addstock_datas[x], stringsAsFactors = F);
  temp[] <- temp[nrow(temp):1,] 
  temp$ticker <- tickers[x];
  temp;})
  df <- do.call("rbind", df)
}


tozsde_plot <- function(number_of_days, my_adatom, list_of_markets){
  
  my_days <- sort(unique(my_adatom$Date), decreasing = T)[c(1:number_of_days)]
  adatom <- data.table(my_adatom[my_adatom$Date %in% my_days,])
  setorder(adatom, ticker, Date)
  
  my_df <- data.table()
  
  for(i in list_of_markets){
    tmp_data <-adatom[ticker==i,]
    current <- tmp_data$Close[1]
    change <- c(0, (( tmp_data$Close[2:number_of_days]/current)-1)*100)

    tmp_data$change <- change
    my_df <- rbind(my_df, tmp_data)
    
  }
  f <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  x <- list(
    title = "Date",
    titlefont = f
  )
  y <- list(
    title = "Change (%)",
    titlefont = f
  )
  p<-plot_ly(my_df, x = ~Date, y = ~change, color =~ticker, text= ~Close)%>%
    add_lines()%>%layout(title = paste(number_of_days, 'Days'), xaxis = x, yaxis = y)
  
  return(p)
  
}
