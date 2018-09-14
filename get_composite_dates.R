dates = read.delim('/media/dan/earth_engine/MODIS_006_MCD43A4.txt', stringsAsFactors = F)[,1]

dates = as.Date(dates, '%Y_%m_%d')

#split into composites
get_layer_date = function(dates, temporal_composite = 8){
  x = split(dates, ceiling(seq_along(dates)/temporal_composite))
  x = do.call(c,lapply(x,mean))
  return(x)
}
a = get_layer_date(dates, 8)

library(raster)

a = raster(matrix(1, ncol = 3, nrow = 3))

cube = brick(lapply(1:30, function(x) x * a))

agg = aggregate(cube, fact = c(1, 1, 8))
