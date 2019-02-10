library('data.table')
library('raster')
library('sf')
#load previous processing
work.dir = '/media/dan/react_data/post_proc/'
modis_base = 'MOD11A2'
variable = 'LST_Day'
out_dir = file.path(work.dir, paste0('output_', modis_base))
old = readRDS(file.path(out_dir, paste0(variable, 'city_bricks.rds')))

#Compare at kinshasa
kin_old = old[[1]]
kin_new = brick('/media/dan/ee_res/Kinshasa_MOD11A2_006_LST_Day_1km_2004_2016.tif')


#see what the data points compare to
dat = fread('/media/dan/pr_data.csv')
dat = dat[get('Name of City') == 'Kinshasa',]
pts = dat[,.(Long, Lat)]

ex_old = raster::extract(kin_old[[1]]*9/5 + 32, pts)
ex_new = raster::extract((kin_new[[1]] - 273.15)*9/5 + 32, pts)
plot(ex_old,ex_new)

a = kin_old[[1]]
b = kin_new[[1]]
d = brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD11A2_LST_Day_1km_2004.tif')[[1]]
qa = brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD11A2_QC_Day_2004.tif')[[1]]

#compare good qavalues
#old codes
code.dir = '/home/dan/Documents/code/react/'
for(ddd in c('MODIS_and_raster_processing_functions.R','download_modis_fun.R', 'extract_tiles_fun.R', 'setup_processing.R', 'city_functions.R')) source(paste0(code.dir,ddd))
qc_table = build_MODIS_QC_table('LST')
qc_table <- subset(x=qc_table,QA_word1 == "LST Good Quality" | QA_word1 =="LST Produced,Check QA")
qc_table <- subset(x=qc_table,QA_word2 == "Good Data" | QA_word2 =="Other Quality")
oldcodes = qc_table$Integer_Value

#new codes
code.dir = '/home/dan/Documents/code/earth_engine/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))
newcodes = build_lst_qa()

addedcodes =newcodes[!newcodes %in% oldcodes]
missingcodes = oldcodes[!oldcodes %in% newcodes]

#assuming oldstyle is correct
qc_table_all = build_MODIS_QC_table('LST')
setDT(qc_table_all)
qc_table_all[Integer_Value %in% addedcodes,]

#twomaps
qa_old = qa %in% oldcodes
qa_new = qa %in% newcodes
qas = brick(qa_old, qa_new)
plot(qas)
#looks like the codes produce the same results, at least for this example

#compare input data
#old style
infile_modis_grid <- "/home/dan/Documents/react_data/modis_grid/modis_sinusoidal_grid_world.shp" #param11
modis_grid<-st_read(infile_modis_grid)
infile_reg_outline<- "/home/dan/Documents/react_data/Cities_React/Boundaries.shp" #param9 '/home/dan/Documents/react_data/Cities_React/roi_1.shp' #
reg_outline <- st_read(infile_reg_outline)
reg_outline_sin <- st_transform(reg_outline,st_crs(modis_grid)$proj4string)

kin = reg_outline_sin[1,]
#find which tiles cover kishasa
kin_tiles = st_intersection(kin, modis_grid) #h19v09
library('MODIS')
kin_modis = '/media/dan/react_data/post_proc/output_MOD11A2/h19v09/MOD11A2.A2004001.h19v09.006.2015212185826.hdf'
met = MODIS::getSds(kin_modis)
kin_modis = raster(met$SDS4gdal[1])
bb = st_bbox(kin)
ext = extent(bb[1],bb[3],bb[2],bb[4])
kin_modis = crop(kin_modis, ext)

#compare the qa layers
kin_qa_modis = crop(raster(met$SDS4gdal[2]),ext)

#compare new and old in raw format
old_raw = kin_modis
new_raw = brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD11A2_LST_Day_1km_2004.tif')[[1]] *.02
new_raw[new_raw == 0] = NA

#compare a and b in lat long
bb_ll = st_bbox(reg_outline[,1])
ext_ll = extent(bb_ll[1],bb_ll[3],bb_ll[2],bb_ll[4])

b = b -273.15
a = crop(a, ext_ll)
b = crop(b, ext_ll)

pts = as.data.frame(a, xy = T)[,c('x','y')]

exa = extract(a, pts)
exb = extract(b, pts)

#compare names
oldnames = names(kin_old)
newnames = read.table('/media/dan/googledrive/MODIS_006_MYD11A2.txt',header = F, stringsAsFactors = F)[,1]
olddates = as.Date(substr(oldnames, 2, 100),"%Y%j")
newdates = as.Date(newnames, '%Y_%m_%d')



