#!/home/mihaly/anaconda3/bin/python
from datetime import datetime
import pandas as pd
from pandas_datareader import data as dreader
from datetime import datetime, timedelta
import sys
import os
os.chdir("/home/mihaly/Desktop/stock_data")

d= pd.read_csv('http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download')
#pd.read_csv('http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download')

my_list=list(set(d[d.Symbol.str.contains("\\^")==False].Symbol))
print (len(my_list))
end = datetime.today().strftime("%Y-%m-%d")
def my_download(each_code):
    try:
        print(each_code)
        b = dreader.DataReader(each_code,'yahoo','1900-01-01',end)
        b['ticker']= each_code
        b['ny'] = 1
        b.to_csv(each_code+'.csv')
        szamlalo= szamlalo+1
    except:
        pass

from multiprocessing import Pool
p = Pool(8)
p.map(my_download, my_list)

print('NYSE data daownoaded')

