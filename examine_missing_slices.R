#Libs
library('sf')
library('data.table')
library('googledrive')
library('raster')

code.dir = '/home/dan/Documents/code/earth_engine/'
out.dir = '/media/dan/ee_res/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)
datafolder = '/media/dan/googledrive/gdrive/modis/'
layerfolder = '/media/dan/googledrive/'
#possible
report_n_slices =function(location_name, metadata){
  message(location_name)
  if(grepl(' ', location_name, fixed = T)){
    warning('Removing spaces from location name')
    location_name = gsub(pattern = ' ', '', x = location_name, fixed = T)
  }
  yst = metadata[,year_start]
  ynd = metadata[,year_end]
  dras = file.path(datafolder,paste0(location_name, '_',metadata[,product],'_',metadata[,variables],'_',yst:ynd,'.tif'))
  dras = do.call(rbind, lapply(dras, function(x) dim(brick(x))))
  dras = as.data.table(dras)
  dras[, loc := location_name]
  dras[, year := 2000 +.I]

  return(dras)
}
lst[,id:=.I]
lst[product %in% c('MOD11A2'),id]

lst_day = lapply(listofcities, function(x) report_n_slices(x, lst[1,]))
lst_day = rbindlist(lst_day)
lst_day[V3!= 46 & year!=2001,]

lst_night = lapply(listofcities, function(x) report_n_slices(x, lst[3,]))
lst_night = rbindlist(lst_night)
lst_night[V3!= 46 & year!=2001,]

metadata = lst[1,]
namepath = file.path(layerfolder, paste0(metadata[,sensor],ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
nnn = read.delim(namepath, header = F, stringsAsFactors = F)[[1]]
lstdates = data.table(date = nnn)
lstdates[, c('y','m','d'):= tstrsplit(date, "_", fixed = T)]
lstdates[,c('y','m','d'):=lapply(.SD, as.numeric), .SDcols = c('y','m','d')]

lst_day = merge(lst_day, lstdates[,.N, by = 'y'], by.x = 'year',by.y ='y')
lst_night = merge(lst_night, lstdates[,.N, by = 'y'], by.x = 'year',by.y ='y')


vis[,id:=.I]
vis = vis[product %in% c('MOD13A1'),]

evi = lapply(listofcities, function(x) report_n_slices(x, vis[1,]))
evi = rbindlist(evi)

metadata = vis[1,]
namepath = file.path(layerfolder, paste0(metadata[,sensor],ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
nnn = read.delim(namepath, header = F, stringsAsFactors = F)[[1]]
evidates = data.table(date = nnn)
evidates[, c('y','m','d'):= tstrsplit(date, "_", fixed = T)]
evidates[, c('y','m','d'):= tstrsplit(date, "_", fixed = T)]
evidates[,c('y','m','d'):=lapply(.SD, as.numeric), .SDcols = c('y','m','d')]

evi = merge(evi, evidates[, .N, by = 'y'], by.x ='year',by.y = 'y')


reflect[,id:=.I]
ref = lapply(listofcities, function(x) report_n_slices(x, reflect[1,]))
ref = rbindlist(ref)
metadata = reflect[1,]
namepath = file.path(layerfolder, paste0(metadata[,sensor],ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
nnn = read.delim(namepath, header = F, stringsAsFactors = F)[[1]]
refdates = data.table(date = nnn)
refdates[, c('y','m','d'):= tstrsplit(date, "_", fixed = T)]
refdates[, c('y','m','d'):= tstrsplit(date, "_", fixed = T)]
refdates[,c('y','m','d'):=lapply(.SD, as.numeric), .SDcols = c('y','m','d')]

ref = merge(ref, refdates[, .N, by = 'y'], by.x ='year',by.y = 'y')
