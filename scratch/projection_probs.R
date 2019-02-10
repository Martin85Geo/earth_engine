library('sp')
library('MODIS')
library('googledrive')
library('sf')
library('rgdal')

#Area of interest
# area = raster::extent(c(7.183258, 7.541592, 4.933307, 5.291641))
# area = as(area, 'SpatialPolygons')
# crs(area) = CRS("+proj=longlat +datum=WGS84 +no_defs")
modis_fp = "/media/dan/react_data/MOD13A1.A2004001.h18v08.006.2015154120518.hdf"
modis = raster(MODIS::getSds(modis_fp)$SDS4gdal[1])
ee = brick('/media/dan/earth_engine/MOD13A1/Lome/Lome_MOD13A1_NDVI_2004.tif')[[1]]

ogras = ee
crs(ogras) = crs(modis)

modis_crs = as.character(crs(ogras)) #'+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs'

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp", stringsAsFactors = F)
city = city_shape[city_shape$Name == 'Lome',]
city_norm = as(city, 'Spatial')
city_adj = city_norm
crs(city_adj) = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

city_norm_modis = spTransform(city_norm, CRS(modis_crs))
city_adj_modis = spTransform(city_adj, CRS(modis_crs))


#raster in the modis projection
#Fake a modis scene h18v08 for MOD13A1
# ras = raster(nrows = 2400, ncols = 2400, xmn = 0, xmx = 1111951, ymn = 0, ymx = 1111951,
#                  crs = '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs',
#                  resolution = 463.3127)
# ras[] = rnorm(ncell(ras))

ras_1 = crop(modis, city_norm_modis)
ras_2 = crop(modis, city_adj_modis)

ras_1_proj = projectRaster(ras_1, crs = crs(city_norm))
ras_2_proj = projectRaster(ras_2, crs = crs(city_adj))


plot(ras_1_proj)
plot(city_norm, add = T)

plot(ras_2_proj)
plot(city_adj, add = T)


# 
# #Crop to the area of interest
# area_modis = spTransform(area, crs(ras))
# 
# ras = crop(ras, area_modis)

# This should show nice overlap
# plot(ras)
# plot(area_modis, add = T)

#Project raster for latlong
# ras_1 = projectRaster(ras, crs = crs(area))
# 
# plot(ras_1)
# plot(area, add = T)


