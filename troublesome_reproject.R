library('sf')
library('raster')

template_grid = raster('/home/dan/Documents/react_data/Cities_React/template_grid.tif') #should be ~1km2, from the tif Dropbox\REACT_shared\WP2_Database\Reference_grid_1km
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp", stringsAsFactors = F)
lome = city_shape[city_shape$Name == 'Lome',]

start_ras = brick("/media/dan/earth_engine//MOD13A1/Lome/Lome_MOD13A1_EVI_2005.tif")[[1]]

#reproject lome study area to the modis projection just for gigs
lome_sinu = st_transform(lome, as.character(crs(start_ras)))

#intial plot--- this is naughty
plot(start_ras)
plot(as(lome_sinu, 'Spatial'), add = T)
