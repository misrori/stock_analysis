
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
  
  
  for (i in list_of_markets) {
    baseline <- adatom[ticker == i, Close][1]
    adatom[ticker == i, change := (Close/baseline-1)*100]
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
  
  m <- list(
    l = 100,
    r = 100,
    b = 10,
    t = 150,
    pad = 4
  )
  p<-plot_ly(adatom, x = ~Date, y = ~change, color =~ticker, text= ~Close)%>%
    add_lines()%>%layout(title = paste(number_of_days, 'Days'), xaxis = x, yaxis = y, height = 900, width = 1000)%>%
    subplot(nrows=100, shareX = T )
  
  return(p)
  
}

get_company_list <- function(){
  
  comp_list1 = read.csv('http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download', stringsAsFactors = F)
  comp_list1$ny <- 0
  comp_list2 = read.csv('http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download', stringsAsFactors = F)
  comp_list2$ny <- 1
  comp_list<- data.table(rbind(comp_list1,comp_list2))
  
  #cleaning
  comp_list <- comp_list[,-c(5,8,9), with=F]
  comp_list <-comp_list[-grep("\\^",comp_list$Symbol),  ]
  comp_list <-comp_list[duplicated(comp_list$Name)==F,]
  comp_list[MarketCap=='/a',]$MarketCap <- '0'
  comp_list[MarketCap=='n/a',]$MarketCap <- '0'
  
  
  comp_list$LastSale <- as.numeric(comp_list$LastSale)
  

  for (i in 1:nrow(comp_list)){
    comp_list$MarketCap[i] <- substr(comp_list$MarketCap[i], 2,nchar(comp_list$MarketCap[i]))
  }
  
  for (i in 1:nrow(comp_list)){
    if (endsWith(comp_list$MarketCap[i],"B")) {
      comp_list$MarketCap[i] <- as.numeric(substr(comp_list$MarketCap[i], 1,nchar(comp_list$MarketCap[i])-1))
    }
    
    if (endsWith(comp_list$MarketCap[i],"M")) {
      comp_list$MarketCap[i] <- as.numeric(substr(comp_list$MarketCap[i], 1,nchar(comp_list$MarketCap[i])-1))/1000
    }
  }
  
  
  comp_list$MarketCap <- as.numeric(comp_list$MarketCap)
  return(comp_list)
  
}


summary_adathoz <- function(number_of_days, my_adatom, list_of_markets){
    
    my_days <- sort(unique(my_adatom$Date), decreasing = T)[c(1:number_of_days)]
    adatom <- data.table(my_adatom[my_adatom$Date %in% my_days,])
    setorder(adatom, ticker, Date)
    
    
    for (i in list_of_markets) {
      baseline <- adatom[ticker == i, Close][1]
      adatom[ticker == i, change := (Close/baseline-1)*100]
    }
    
    return(adatom[, .SD[.N], by="ticker"])
    
}


