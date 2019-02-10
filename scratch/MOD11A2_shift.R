library('sp')
library('MODIS')
library('googledrive')

#Load the modis scene associated with Dar es Salaam/bounding box specificed below
modis_fp = '/media/dan/react_data/post_proc/output_MOD11A2/h21v09/MOD11A2.A2004001.h21v09.006.2015212185901.hdf'
modis = raster(MODIS::getSds(modis_fp)$SDS4gdal[1])

#define bbox
bbox= c(38.94993166800003, 39.44200277300007, -7.127943276999929,-6.552704129999938)
bbox = extent(bbox)
bbox_crs = CRS('+init=epsg:4326')

#reproject to the SDS's CRS
bbox = as(bbox, "SpatialPolygons") #changes object type-- shouldn't change the geometry
crs(bbox) = bbox_crs #set the CRS
#bbox's starting projection should be latlong/wgs84
#convert to +proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs, which is what modis is
bbox = sp::spTransform(bbox, CRSobj = crs(modis))

#use bbox to crop the raw modis data
dar_modis = crop(modis, bbox)

#download similiar/same data from earth engine
dar_ee = raster(drive_download(drive_get('dar_bbox.tif'), overwrite = T)$local_path)

#apply scaling and set 0 to NA
dar_ee[dar_ee==0] = NA
dar_ee = dar_ee * .02

#check if the resolutions are the same
res(dar_ee) == res(dar_modis) #This returns false, but the difference is -8.366794e-08

#for some reason, dar ee has a larger dimensions, crop to try to match the raw modis
dar_ee = crop(dar_ee, dar_modis)



