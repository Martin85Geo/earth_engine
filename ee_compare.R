library(raster)
#h19v9
bla = '/home/dan/Downloads/MOD13A1.A2004001.h21v09.hdf'

#Get the metadata from the file
metadat = MODIS::getSds(bla)

#extract the layers
ras = raster(metadat$SDS4gdal[1])

infile_modis_grid <- "/home/dan/Documents/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)


infile_reg_outline<- "/home/dan/Documents/react_data/Cities_React/Boundaries.shp" #param9 '/home/dan/Documents/react_data/Cities_React/roi_1.shp' #
reg_outline <- st_read(infile_reg_outline)
reg_outline_sin <- st_transform(reg_outline,st_crs(modis_grid)$proj4string)


dar = reg_outline_sin[2,]
bb = st_bbox(dar)
ext = extent(bb[1],bb[3],bb[2],bb[4])

#crop thangs
blarg = crop(ras, ext)

#writeRaster('')