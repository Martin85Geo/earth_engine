library('sf')
library('raster')
library('data.table')

code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/earth_engine/srtm/'
ooot = '/media/dan/ee_processed/srtm/latlong/'
dir.create(ooot, recursive = T)
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'create_variables_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)


for(city in listofcities){
  
  ras = readAll(raster(paste0(datadir, city,'/',city, '_srtm.tif')))
  
  for(var in c('slope','aspect','TPI','TRI','roughness', 'elevation')){
    
    
    rasname = paste0(paste(city,'srtm','01',var,2000,2000,sep='_'),'.tif')
    
    if(var == 'elevation'){
      writeRaster(ras, paste0(ooot, rasname), overwrite = T)
    } else{
      a = terrain(ras, opt = var, filename = paste0(ooot, rasname), overwrite = T)
    }
  }
  
  
}
