# you have to run the two python scripts to get the data 
source('my_functions.R')
library(data.table)
library(rio)
stock <- fread('~/Desktop/stock_data/00all_data.csv') 
stock <- stock[ticker!="ticker", ]
stock$Date <- as.Date(stock$Date)


export(stock[,c(1,5,8, 9),with=F], '0_step_get_the_data/Stock_data.RData')

rm(stock)

adat <- data.table(import('0_step_get_the_data/Stock_data.RData'))

comp_list <- data.table(get_company_list())

belepes <- adat[,list(belepes=min(Date)),by='ticker']

#basic_info + belepes
setkey(belepes, 'ticker')
setkey(comp_list,'Symbol')
comp_list <- comp_list[belepes]
comp_list$Sector <- gsub(' ', '_',tolower(comp_list$Sector))
comp_list$industry <- gsub(' ', '_',tolower(comp_list$industry))

export(comp_list, '0_step_get_the_data/comp_list.RData')
