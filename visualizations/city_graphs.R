library('ggplot2')
library('ggmap')
library('sf')
library('data.table')
library('raster')
library(tools)
library(viridis)  # better colors for everyone
library(ggthemes)
library('rasterVis')

datadir = '/media/dan/ee_res/brdf/latlong/'
ooot = '/media/dan/ee_res/indices/'
meeting_dir = '/media/dan/graphics/sept5/'
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

#raster time series
for(city_name in listofcities){
  print(city_name)
  og_city = city_name
  city_name = gsub(" ", replacement = "",x = city_name)
  fff = paste0('/media/dan/earth_engine/NIGHTTIME_LIGHTS/',city_name, '/', city_name, '_NIGHTTIME_LIGHTS_avg_vis_', 1992:2013,'.tif ')
  ntl = brick(lapply(fff, function(x) mean(brick(x))))
  names(ntl) = 1992:2013
  # png(paste0(meeting_dir, city_name, '_timeseries_raster.png'), height = 8, width = 10, unit = 'in', res = 300)
  # print(spplot(ntl, zcol = names(ntl)))
  # dev.off()
  
  ntl = as.data.frame(ntl)
  setDT(ntl)
  ntl[, id:=.I]
  ntl = melt(ntl, id.vars = 'id')
  
  ntl_mean = ntl[, list(value = mean(value, na.rm = T)), by = 'variable']
  ntl_mean[, id:=-1]
  ntl_plt = ntl[id %in% sample(unique(ntl$id), size = 150),]
  
  g = ggplot(ntl_plt, aes(x = variable, y = value, group = id)) + geom_line(alpha = .1) + theme_bw() + 
    geom_line(data = ntl_mean, color = 'red') +
    ggtitle(paste0('NTL trajectories for ', og_city))
  ggsave(paste0(meeting_dir, city_name, '_timeseries_px.png'),plot = g,device = 'png',width = 12, height = 9, units = 'in', dpi = 300)
  
  
  
}





# 
# ndwi_lagos = brick(paste0(ooot,'ndwi_nirswi_Lagos_1_8.tif'))
# ndwi_dakar = brick(paste0(ooot,'ndwi_nirswi_Dakar_1_8.tif'))
# 
# #date function
# dates = read.delim('/media/dan/earth_engine/MODIS_006_MCD43A4.txt', stringsAsFactors = F)[,1]
# dates = as.Date(dates, '%Y_%m_%d')
# #split into composites
# get_layer_date = function(dates, temporal_composite = 8){
#   x = split(dates, ceiling(seq_along(dates)/temporal_composite))
#   x = do.call("c" ,lapply(x,mean.Date))
#   return(x)
# }
# 
# #create maps of seasonality
# layer_dates = get_layer_date(dates)
# month_id = month(layer_dates)
# 
# lagos_season = lapply(unique(month_id), function(x) mean(as.array(ndwi_lagos)[,,which(month_id == x)], na.rm = T))
# lagos_season = unlist(lagos_season)
# 
# dakar_season = lapply(unique(month_id), function(x) mean(as.array(ndwi_dakar)[,,which(month_id == x)], na.rm = T))
# dakar_season = unlist(dakar_season)
# 
# gdat = data.table(month_id = 1:12, month = month.abb, city = c(rep('Dakar', 12),rep('Lagos', 12)), ndwi = c(dakar_season, lagos_season))
# gdat[, month_fact := factor(month, levels = month.abb)]
# 
# #seasonal trends
# g = ggplot(gdat, aes(x = month_fact, y = ndwi, group = city)) + geom_line() + theme_bw() + facet_wrap(~city) +
#   xlab('Month') + ylab('NDWI') + ggtitle('Seasonal Trends in NDWI') + 
#   theme(strip.text.x = element_text(size = 20), plot.title = element_text(size=24))
# plot(g)
# ggsave(paste0(meeting_dir, 'seasonal_trends.png'), plot = g, width = 10, height = 6, units = 'in', dpi = 300)
# 
# 
# #time series for Dakar
# ts_dakar = as.array(ndwi_dakar)
# ts_dakar = unlist(lapply(1:dim(ts_dakar)[3], function(x) mean(ts_dakar[,,x], na.rm =T)))
# ts_dakar = data.table(date = layer_dates, ndwi = ts_dakar)
# 
# g = ggplot(ts_dakar, aes(x = date, y = ndwi)) + geom_line() + theme_bw() + ggtitle('Dakar, NDWI 2001-2016') +
#   xlab('Date') + ylab('NDWI')
# ggsave(paste0(meeting_dir, 'dakar_time_series.png'), plot = g, width = 10, height = 10, units = 'in', dpi = 300)


