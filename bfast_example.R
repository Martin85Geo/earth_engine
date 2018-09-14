#Libs
library('sf')
library('data.table')
library('raster')
library('xts')
library('bfast')

code.dir = '/home/dan/Documents/code/earth_engine/'
datadir = '/media/dan/ee_res/brdf/latlong/'
ooot = '/media/dan/graphics/sept5/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'bfast_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)

#generate raster files to operate on
cities = c('Ouagadougou', "Dakar")
ras_files = paste0('/media/dan/ee_processed/', 'MOD13A1/latlong/', cities, '_MOD13A1_006_NDVI_2001_2016.tif' )
date_file = '/media/dan/earth_engine/MODIS_006_MOD13A1.txt'

img = load_brick(ras_files[2], date_file)
dates = as.Date(substr(names(img), 2, 9999),format = '%Y_%m_%d')
# 
# bf1 = bfast_pixel(5000, img,dates = dates, return_model = T)
# bf2 = bfast_pixel(5000, img,dates = dates, h = .2, return_model = T)
# bf3 = bfast_pixel(5000, img,dates = dates, nbrk = 2, return_model = T)
# 
# png(paste0(ooot, 'bfast_dakar_5000_h15.png'), width = 10, height = 8, unit = 'in', res = 300)
# plot(bf1[[2]])
# dev.off()
# 
# png(paste0(ooot, 'bfast_dakar_5000_h2.png'), width = 10, height = 8, unit = 'in', res = 300)
# plot(bf2[[2]])
# dev.off()
# 
# png(paste0(ooot, 'bfast_dakar_5000_h15_nbrk2.png'), width = 10, height = 8, unit = 'in', res = 300)
# plot(bf3[[2]])
# dev.off()

#load some outputs

bf = readRDS(paste0('/media/dan/bfast/','Dakar','_', 1, '.rds'))
bf[, c('m','l','u', 'mag') := NULL]
bf[, c('m','l','u', 'mag') := as.double(NA)]
for(i in 1:5){
  for(j in c('m','l','u', 'mag')){
    bf[!is.na(get(paste0(j,'_',i))), paste0(j) := get(paste0(j,'_',i))]
  }
}

template = img[[1]] * NA

#any breakpoint
any_break = template
any_break[bf[,index]] = !is.na(bf[,m])

#number of breakpoints
num_break = template
num_break[] = bf[, num_bp_vt]

#magnitude of the largest break
lg_break = template
lg_break[] = bf[, mag]

#latest break year
late_break = template
late_break[] = year(dates[bf[, m]])

#check to see if a pixel had a break in a particular year
yyy = unique(year(dates))
brk_yr = brick(lapply(unique(year(dates)), function(x) template))
brk_yr[] = 0

for(i in 1:dim(brk_yr)[3]){
  for(j in 1:5){
    px = bf[year(dates[get(paste0('m_',j))]) == yyy[i] , index]
    months = month(dates[bf[index %in% px, get(paste0('m_',j))]])
    
    brk_yr[[i]][px] = months
  }
}

names(brk_yr) = yyy

#calculate breaks
png(paste0(ooot, 'bfast_dakar_num_break.png'), width = 10, height = 8, unit = 'in', res = 300)
spplot(num_break)
dev.off()

png(paste0(ooot, 'bfast_dakar_lg_break.png'), width = 10, height = 8, unit = 'in', res = 300)
spplot(lg_break)
dev.off()

png(paste0(ooot, 'bfast_dakar_late_break.png'), width = 10, height = 8, unit = 'in', res = 300)
spplot(late_break)
dev.off()

png(paste0(ooot, 'bfast_dakar_break_year.png'), width = 10, height = 8, unit = 'in', res = 300)
spplot(brk_yr)
dev.off()
