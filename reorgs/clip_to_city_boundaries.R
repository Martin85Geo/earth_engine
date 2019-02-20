#a script to load a raster file, crop it to the relevant city boundary, and resave
library(raster)
library('data.table')
library('sf')

sg= readRDS(paste0('/media/dan/summary_grid.rds'))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)

clip_ras = function(ras_path){
  
  backup = sub('processed', 'processed_unclipped_copy', ras_path, fixed = T)
  dir.create(dirname(backup), recursive = T)
  # file.copy(ras_path, backup)
  
  city_name = strsplit(basename(ras_path), '_', T)[[1]][1]
  a = raster::brick(ras_path)
  start_dim = dim(a)
  a = raster::crop(a, as(city_shape[city_shape$Name == city_name,], 'Spatial'))
  end_dim = dim(a)
  
  writeRaster(a, filename = ras_path, overwrite = T)
  
  ret = data.table(backup_path = backup, raspath = ras_path)
  ret[, c('sx','sy','sz', 'ex','ey','ez'):= lapply(c(start_dim, end_dim), function(x) x)]
  return(ret)
}

bbb = mclapply(sg$raspath, clip_ras, mc.cores = 4)

bbb = rbindlist(bbb)
saveRDS(bbb, paste0('/media/dan/clip_grid.rds'))
