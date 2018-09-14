#Libs
library('sf')
library('data.table')
library('raster')
library('xts')
library('bfast')

version = 1
code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/ee_res/brdf/latlong/'
ooot = '/media/dan/ee_res/indices/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'bfast_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)

#generate raster files to operate on
cities = c('Ouagadougou', "Dakar")

# for(cit in cities){
# 
#   ras_files = paste0('/media/dan/ee_processed/', 'MOD13A1/latlong/', cit, '_MOD13A1_006_NDVI_2001_2016.tif' )
#   date_file = '/media/dan/earth_engine/MODIS_006_MOD13A1.txt'
#   
#   img = load_brick(ras_files, date_file)
#   dates = as.Date(substr(names(img), 2, 9999),format = '%Y_%m_%d')
#   
#   bf = parallel::mclapply(1:ncell(img), function(x) bfast_pixel(x, img, dates, obs_year = 23, na_thresh = .5, h = .15), 
#                           mc.cores = 7, mc.preschedule = F)
#   
#   bf = rbindlist(bf, fill =T)
#   
#   saveRDS(bf, paste0('/media/dan/bfast/',cit,'_', version, '.rds'))
#   
# }





