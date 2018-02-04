#Libs
library('sf')
library('data.table')
library('googledrive')

code.dir = '/home/dan/Documents/code/earth_engine/'
for(ddd in c('qa_functions.R')) source(paste0(code.dir,ddd))

#Governing variables (after running 00)
product_grid = lst
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")

expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))

thegrid = setDT(expand.grid.df(as.data.frame(product_grid), data.frame(city_name = unique(city_shape$Name))))


#for each product
  #For each city
    #for each year
    #Load dataset and qa

