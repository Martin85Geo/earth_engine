library('sp')
library('MODIS')
library('googledrive')
library('sf')
library('rgdal')

#find the scene associated with Lome
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp", stringsAsFactors = F)
city = city_shape[city_shape$Name == 'Lome',]

#Load template grid and make it 500m2 pixels
template_grid = raster('/home/dan/Documents/react_data/Cities_React/template_grid.tif') #should be ~1km2, from the tif Dropbox\REACT_shared\WP2_Database\Reference_grid_1km
template_grid = disaggregate(template_grid, 2)

#find which tiles it covers
infile_modis_grid <- "/media/dan/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)
city_sin <- spTransform(as(city, 'Spatial'), st_crs(modis_grid)$proj4string)
tiles = st_intersection(modis_grid, city_sin)

#Load the modis scene associated with Lome specified below (h18v08) output_MOD13A1/h18v08/MOD13A1.A2004001.h18v08.006
modis_fp = "/media/dan/react_data/MOD13A1.A2004001.h18v08.006.2015154120518.hdf"
modis = raster(MODIS::getSds(modis_fp)$SDS4gdal[1])

#scale the modis data
modis = modis * .0001

#load the ee image associated with lome
ee = brick('/media/dan/earth_engine/MOD13A1/Lome/Lome_MOD13A1_NDVI_2004.tif')[[1]]

crs(ee) = CRS('+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs')

#crop modis to ee extent
modis_cp = crop(modis, ee)

#confirm they can be equal
all.equal(ee[], modis_cp[])

#see what happens if we use R to do the cropping via polygons
modis_cp_poly = crop(modis, as(city_sin, 'Spatial'))
ee_cp = crop(ee, modis_cp_poly) #that results in a slightly different answer which is resolved by this line

all.equal(ee_cp[], modis_cp_poly[])
compareRaster(ee_cp, modis_cp_poly)

#see what happens when things get transformed to latlong
#presumably this should work-- projecting our modis data into the now ~500m template raster grid that is cropped to the city. Apparently not.
ee_pj1 = projectRaster(ee_cp, crop(template_grid, as(city, 'Spatial')))
plot(ee_pj1)
plot(as(city, 'Spatial'), add = T)

#try just a straight crs transformation
ee_pj2 = projectRaster(ee_cp, crs = crs(template_grid)) #pixels are almost square (.00418 by .00419)
plot(ee_pj2)
plot(as(city, 'Spatial'), add = T) #things still don't line up

#but when the geometry for the city is transformed into sinu, things seem to work alright.
# plot(ee) #plot raster
# plot(as(city_sin, 'Spatial'), add = T) #plot study area for lome


