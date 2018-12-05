library('sf')
library('raster')
library('data.table')

code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/earth_engine/VCMCFG/'
ooot = '/media/dan/ee_processed/VCMCFG/latlong/'
dir.create(ooot, recursive = T)
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'create_variables_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)
year_list = 2012:2016

for(cit in listofcities){
  
  #load all the years of data
  fff = paste0(datadir,cit, '/', cit, '_VCMCFG_avg_rad_', year_list, '.tif')
  
  ras = brick(lapply(fff, function(x) readAll(brick(x))))
  ras = clamp(ras, -1.5, 340573)
  #load all the cloud data
  #skip dropping pixels because of cloud coverage for now
  
  rasname = paste(cit, 'VCMCFG', '01', 'avg_rad',min(year_list), max(year_list), sep = '_')
  
  writeRaster(ras, file.path(ooot, paste0(rasname,'.tif')), overwrite = T)
  
  
}
