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

#create ndwi
the_params = expand.grid(city = listofcities, spatial_agg = c(1,2), temporal_agg = c(8, 16, 30), stringsAsFactors = F)


cl = makeForkCluster(1)
registerDoParallel(cl)

over = 1:nrow(the_params)
foreach(x=over) %dopar% {
  
  print(x)
  
  param = the_params[x,]
  a = create_ndwi(param)
  a = create_ndvi(param)
  a = create_evi(param)
  a = create_tcb(param)
  a = create_tcw(param)
  
  
}

stopImplicitCluster()
stopCluster(cl)


# 
# #create ndvi
# ndvi_params = expand.grid(city = listofcities, spatial_agg = 1:2, temporal_agg = c(8,16,30), stringsAsFactors = F)
# create_ndvi = function(params){
#   
#   red = load_brdf_raster(datafolder = datadir,spectrum = 'nir',city = params$city)
#   nir = load_brdf_raster(datafolder = datadir,spectrum = 'red',city = params$city)
#   res = spacetime_aggregate_nd(red, nir, fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg))
#   
#   #save raster
#   rasname = paste0('ndvi_', paste(params, collapse = "_"), '.tif')
#   
#   writeRaster(res, file.path(datadir,'ndvi', rasname), overwrite = T)
#   
#   return(rasname)
# }
# 
# ndvi = lapply(1:nrow(ndvi_params), function(x) create_ndvi(ndvi_params[x,]))

