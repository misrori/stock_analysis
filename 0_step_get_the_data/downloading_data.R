# you have to run the two python scripts to get the data 
# 
# delete the header  Date,Open,High,Low,Close,Volume,Adj Close,ticker
# sed -i '1d' *.csv
#create one file from all csv
#cat *.csv >>all_data.csv

source('my_functions.R')
library(data.table)
library(rio)
stock <- fread('~/Desktop/stock_data/all_data.csv') 
names(stock) <-c('Date','Open','High','Low','Close','Volume','Adj Close','ticker')
stock$Date <- as.Date(stock$Date)


export(stock[,c(1,5,8),with=F], '0_step_get_the_data/Stock_data.RData')

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
