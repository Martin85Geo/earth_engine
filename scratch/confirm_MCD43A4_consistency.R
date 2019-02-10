library('data.table')
library('sf')
library('raster')
library('httr')
library('MODIS')

#load tiles and boundaries for Kinshasa
city_shape = st_read("/media/dan/react_data/Cities_React/Boundaries.shp")
city = city_shape[1,]
infile_modis_grid <- "/media/dan/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)
city_sin <- st_transform(city,st_crs(modis_grid)$proj4string)
tiles = st_intersection(modis_grid, city_sin)

#load ee
#Jan 1 2010
ee_dat = stack('/media/dan/earth_engine/MCD43A4/Kinshasa/Kinshasa_MCD43A4_Nadir_Reflectance_Band4_2010.tif')[[1]]
ee_qa = stack('/media/dan/earth_engine/MCD43A4/Kinshasa/Kinshasa_MCD43A4_BRDF_Albedo_Band_Mandatory_Quality_Band4_2010.tif')[[1]]

#apply scaling
ee_dat = ee_dat * 0.0001

#download and load lpdaac
if(!file.exists('https://e4ftl01.cr.usgs.gov/MOTA/MCD43A4.006/2010.01.01/MCD43A4.A2010001.h19v09.006.2016072071556.hdf')){
  up = '/home/dan/Documents/react_data/lpdaac.Rdata'
  load(up)
  url = 'https://e4ftl01.cr.usgs.gov/MOTA/MCD43A4.006/2010.01.01/MCD43A4.A2010001.h19v09.006.2016072071556.hdf'
  httr::GET(url, authenticate(username, pass), write_disk('/media/dan/react_data/kinshasa_MCD43A4_2010001.hdf'), overwrite = T)
}else{
  sds = MODIS::getSds('/media/dan/react_data/kinshasa_MCD43A4_2010001.hdf')
  lpd_dat = raster(sds$SDS4gdal[11])
  lpd_qa = raster(sds$SDS4gdal[4])
  
  #crop things
  lpd_dat = crop(lpd_dat, ee_dat)
  lpd_qa = crop(lpd_qa, ee_qa)
  
}



# #find the date with the best coverage
# ras = raster::brick(paste0('/media/dan/ee_res/', as.character(city$Name), '_MCD43A4_006_Nadir_Reflectance_Band4_2001_2016.tif'))
# ras[] = ras[]
# bad_px = lapply(ras, function(x) sum(is.na(x)))
# bad_px = unlist(bad_px)
# 
# #get the slice that has the most data
# best_slice = ras[[which.min(bad_px)]]
# 
# bla = as.vector(ras)
