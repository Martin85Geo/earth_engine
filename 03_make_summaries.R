#Libs
library('sf')
library('data.table')
library('googledrive')
library('raster')
library('foreach')
library('doParallel')


code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/ee_processed/MCD43A4/latlong/'
ooot = '/media/dan/ee_processed/indices/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'create_variables_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)

summarize_variable = function(ras, classification, label, agg_fun = mean){
  
}