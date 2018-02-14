library('sp')
library('data.table')
library('sf')
library('MODIS')
library('googledrive')

#The city is Dar
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
city = city_shape[2,]

#find which tiles it covers
infile_modis_grid <- "/home/dan/Documents/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)
city_sin <- st_transform(city,st_crs(modis_grid)$proj4string)
tiles = st_intersection(modis_grid, city_sin)

city_sin_sp = as(st_zm(city_sin), 'Spatial')


modis_fp = '/media/dan/react_data/post_proc/output_MOD11A2/h21v09/MOD11A2.A2004001.h21v09.006.2015212185901.hdf'
modis = raster(MODIS::getSds(modis_fp)$SDS4gdal[1])
qa = raster(MODIS::getSds(modis_fp)$SDS4gdal[2])

dar_modis = crop(modis, extent(city_sin_sp))
dar_ask1 = raster(drive_download(drive_get('ask1.tif'), overwrite = T)$local_path)
dar_ask2 = raster(drive_download(drive_get('ask2.tif'), overwrite = T)$local_path)

bla = crop(dar_modis,dar_ask1)



