library('sf')
library('raster')
library('data.table')

code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/earth_engine/srtm/'
ooot = '/media/dan/ee_processed/elevation/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'create_variables_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)


for(city in listofcities){
  
  ras = readAll(raster(paste0(datadir, city,'/',city, '_srtm.tif')))
  
  for(var in c('slope','aspect','TPI','TRI','roughness')){
    a = terrain(ras, opt = var, filename = paste0(ooot, city, '_',var,'.tif'), overwrite = T)
  }
}
