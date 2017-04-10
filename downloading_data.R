# you have to run the two python scripts to get the data 
source('my_functions.R')
library(data.table)
library(rio)
stock <- fread('~/Desktop/stock_data/00all_data.csv') 

stock$Date <- as.Date(stock$Date)
stock$Close <- as.numeric(stock$Close)
stock$ticker <- as.factor(stock$ticker)
stock$ny <- as.factor(stock$ny)
stock <- stock[ticker!="ticker", ]

export(stock[,c(1,5,8, 9),with=F], 'Stock_data.RData')

rm(stock)

adat <- data.table(import('Stock_data.RData'))

comp_list <- data.table(get_company_list())

belepes <- adat[,list(belepes=min(Date)),by='ticker']

#basic_info + belepes
setkey(belepes, 'ticker')
setkey(comp_list,'Symbol')
setkey(adat, 'ticker')
comp_list <- comp_list[belepes]
comp_list$Sector <- gsub(' ', '_',tolower(comp_list$Sector))
comp_list$industry <- gsub(' ', '_',tolower(comp_list$industry))

export(comp_list, 'comp_list.RData')
