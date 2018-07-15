library('sf')
library('data.table')
library('raster')
library(tools)

datadir = '/media/dan/ee_res/brdf/latlong/'
ooot = '/media/dan/ee_res/indices/'
meeting_dir = '/media/dan/graphics/may30/'
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

#generate, for each city, the mean, min, max, variance and missing cells for BRDF b1 and NDWi
gen_city_stats = function(ras_path){
 ras = brick(ras_path)
 ras = as.array(ras)
 
 ret_obj = data.table(mean = mean(ras,na.rm =T),
                      min  = min(ras, na.rm =T),
                      max  = max(ras, na.rm = T),
                      variance = sd(ras,na.rm = T)^2,
                      missing_cells = sum(is.na(ras)),
                      total_cells = length(ras))
 ret_obj[, perc_missing := round(missing_cells/total_cells,2) *100]
 
 return(ret_obj)
}
#get stats for brdf band 2
brdf_fps = paste(listofcities, 'MCD43A4', '006','Nadir','Reflectance', 'Band2', '2001','2016.tif', sep = '_')
brdf_fps = paste0(datadir, brdf_fps)
brdf2 = parallel::mclapply(brdf_fps, gen_city_stats, mc.cores = 5)
brdf2 = lapply(1:length(brdf2), function(x) brdf2[[x]][,city:=listofcities[x]])
brdf2 = rbindlist(brdf2)

#get stats for ndwi 1k 8 day
ndwi1k8d_fps = paste('ndwi', 'nirswi', listofcities, '2','8.tif', sep = '_')
ndwi1k8d_fps = paste0(ooot, ndwi1k8d_fps)
ndwi1k8d = parallel::mclapply(ndwi1k8d_fps, gen_city_stats, mc.cores = 5)
ndwi1k8d = lapply(1:length(ndwi1k8d), function(x) ndwi1k8d[[x]][,city:=listofcities[x]])
ndwi1k8d = rbindlist(ndwi1k8d)

#get stats for ndwi 1k 30 day
ndwi1k30d_fps = paste('ndwi', 'nirswi', listofcities, '2','30.tif', sep = '_')
ndwi1k30d_fps = paste0(ooot, ndwi1k30d_fps)
ndwi1k30d = parallel::mclapply(ndwi1k30d_fps, gen_city_stats, mc.cores = 5)
ndwi1k30d = lapply(1:length(ndwi1k30d), function(x) ndwi1k30d[[x]][,city:=listofcities[x]])
ndwi1k30d = rbindlist(ndwi1k30d)

#order and prettify
round_cols = c('mean','min','max', 'variance')
for(ddd in list(brdf2, ndwi1k8d, ndwi1k30d)){
  ddd[,city:=toTitleCase(city)]
  ddd[,(round_cols) := lapply(.SD, function(x) round(x, 2)), .SDcols = round_cols]
  ddd[, missing_cells := prettyNum(missing_cells, big.mark = ',')]
  ddd[, total_cells := prettyNum(total_cells, big.mark = ',')]
  setcolorder(ddd, c('city'))
  setorder(ddd, +city)
  
  oldnames = c("mean", "min", "max", "variance", "missing_cells", "total_cells", 
               "perc_missing", "city")
  newnames = c('Mean','Min','Max','Variance','# Missing Cells', '# Total Cells', '% Missing Cells', 'City')
  
  setnames(ddd, oldnames, newnames)
}

#save files
write.csv(brdf2, file = paste0(meeting_dir, 'brdf2_summary_city.csv'), row.names = F)
write.csv(ndwi1k8d, file = paste0(meeting_dir, 'ndwi_1k8d_summary_city.csv'), row.names = F)
write.csv(ndwi1k30d, file = paste0(meeting_dir, 'ndwi_1k30d_summary_city.csv'), row.names = F)
