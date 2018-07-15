library('ggplot2')
library('ggmap')
library('sf')
library('data.table')
library('raster')
library(tools)
library(viridis)  # better colors for everyone
library(ggthemes)

datadir = '/media/dan/ee_res/brdf/latlong/'
ooot = '/media/dan/ee_res/indices/'
meeting_dir = '/media/dan/graphics/may30/'
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

#map of dakar
dakar_fp = paste('Dakar', 'MCD43A4', '006','Nadir','Reflectance', 'Band2', '2001','2016.tif', sep = '_')
dakar_fp = paste0(datadir, dakar_fp)
dakar = brick(dakar_fp)
dak_arr = as.array(dakar)

#find the scene with lowest missingness
mis_dakar = unlist(lapply(1:dim(dak_arr)[3], function(x) sum(is.na(dak_arr[,,x]))/length(dak_arr[,,3])))
dakar_sing = dakar[[which.min(mis_dakar)]]

#map of lagos
lagos_fp = paste('Lagos', 'MCD43A4', '006','Nadir','Reflectance', 'Band2', '2001','2016.tif', sep = '_')
lagos_fp = paste0(datadir, lagos_fp)
lagos = brick(lagos_fp)
lagos_arr = as.array(lagos)

#find the scene with lowest missingness
mis_lagos = unlist(lapply(1:dim(lagos_arr)[3], function(x) sum(is.na(lagos_arr[,,x]))/length(lagos_arr[,,3])))
lagos_sing = lagos[[which.min(mis_lagos)]]

#A single image for
#Dakar
png(paste0(meeting_dir, 'dakar_NIR.png'), width = 10, height = 10, units = 'in', res = 300)
spplot(dakar_sing, main=list(label="Dakar | NIR",cex=2))
dev.off()

#Lagos
png(paste0(meeting_dir, 'lagos_NIR.png'), width = 10, height = 10, units = 'in', res = 300)
spplot(lagos_sing, main=list(label="Lagos | NIR",cex=2))
dev.off()

#Means for dakar and lagos
ndwi_lagos = brick(paste0(ooot,'ndwi_nirswi_Lagos_1_8.tif'))
ndwi_dakar = brick(paste0(ooot,'ndwi_nirswi_Dakar_1_8.tif'))
dakar_mean = mean(ndwi_dakar, na.rm = T)
lagos_mean = mean(ndwi_lagos, na.rm = T)

png(paste0(meeting_dir, 'dakar_ndwi.png'), width = 10, height = 10, units = 'in', res = 300)
spplot(dakar_mean, main=list(label="Dakar, NDWI 2001-2016",cex=1))
dev.off()

#Lagos
png(paste0(meeting_dir, 'lagos_ndwi.png'), width = 10, height = 10, units = 'in', res = 300)
spplot(lagos_mean, main=list(label="Lagos, NDWI 2001-2016",cex=1))
dev.off()

#Create seasonal maps for Dakar
dates = read.delim('/media/dan/earth_engine/MODIS_006_MCD43A4.txt', stringsAsFactors = F)[,1]
dates = as.Date(dates, '%Y_%m_%d')
#split into composites
get_layer_date = function(dates, temporal_composite = 8){
  x = split(dates, ceiling(seq_along(dates)/temporal_composite))
  x = do.call("c" ,lapply(x,mean.Date))
  return(x)
}
layer_dates = get_layer_date(dates)
month_id = month(layer_dates)
ndwi_dakar = readAll(ndwi_dakar)
dakar_season_map = brick(parallel::mclapply(unique(month_id), function(x) mean(ndwi_dakar[[which(month_id == x)]], na.rm = T), mc.cores = 4))
names(dakar_season_map) = month.abb

png(paste0(meeting_dir, 'dakar_ndwi_seasonal.png'), width = 10, height = 10, units = 'in', res = 300)
spplot(dakar_season_map, main=list(label="Dakar, NDWI Seasonal Patterns",cex=1))
dev.off()