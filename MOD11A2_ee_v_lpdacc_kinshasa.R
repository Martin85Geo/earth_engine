library('sp')
library('MODIS')
library('googledrive')
library('sf')

#find the scene associated with kinshasa
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
city = city_shape[1,]

#find which tiles it covers
infile_modis_grid <- "/home/dan/Documents/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)
city_sin <- st_transform(city,st_crs(modis_grid)$proj4string)
tiles = st_intersection(modis_grid, city_sin)

#Load the modis scene associated with Kinshasa/bounding box specified below (h19v09)
modis_fp = '/media/dan/react_data/post_proc/output_MOD11A2/h19v09/MOD11A2.A2004001.h19v09.006.2015212185826.hdf'
modis = raster(MODIS::getSds(modis_fp)$SDS4gdal[1])

#define bbox (in EPSG:4326)
kin_bbox = st_bbox(city)
#xmin      ymin      xmax      ymax 
#15.166210 -4.549408 15.598775 -4.289019
bbox= c(15.166210, 15.598775, -4.549408,-4.289019)
bbox = extent(bbox)
bbox_crs = CRS('+init=epsg:4326')

#reproject to the SDS's CRS
bbox = as(bbox, "SpatialPolygons") #changes object type-- shouldn't change the geometry
crs(bbox) = bbox_crs #set the CRS
#bbox's starting projection should be latlong/wgs84
#convert to +proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs, which is what modis is
bbox = sp::spTransform(bbox, CRSobj = crs(modis))

#use bbox to crop the raw modis data
kin_modis = crop(modis, bbox)

#download similiar/same data from earth engine
kin_ee = raster(drive_download(drive_get('kin_bbox.tif'), overwrite = T)$local_path)

#apply scaling and set 0 to NA
kin_ee[kin_ee==0] = NA
kin_ee = kin_ee * .02

#check if the resolutions are the same
round(res(kin_ee),4) == round(res(kin_modis),4) #Are they up to 4 decimal poins the same?

#for some reason, dar ee has a larger dimensions, crop to try to match the raw modis
kin_ee = crop(kin_ee, bbox)

plot(kin_ee == kin_modis)

