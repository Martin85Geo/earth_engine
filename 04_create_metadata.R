#Libs
library('sf')
library('data.table')
library('googledrive')
library('raster')
library('foreach')
library('doParallel')
library('zoo')


code.dir = '/home/dan/Documents/code/earth_engine/'
layerfolder = '/media/dan/earth_engine/'
out.dir = '/media/dan/processed/'
dir.create(out.dir)

for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'summarize_functions.R',
             'metadata_functions.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
listofcities = as.character(city_shape$Name)
expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)

#lst
lst_vars = lst
lst_vars = lst_vars[, prefix := product ]
lst_vars = lst_vars[product== 'MOD11A2',]

#VI
vis_vars = vis
vis_vars[, prefix := product ]
vis_vars = vis_vars[product== 'MOD13A1',]

#brdf bands
brdf_bands = brdf
brdf_bands[, prefix:= product]

dat = rbindlist(list(lst_vars, vis_vars,brdf_bands), fill = T)
dat[, calc_time:= F]

brdf_vars = expand.grid(product = 'MCD43A4', version = '006', var_base = c('ndwi_nirswi', 'ndvi','evi','tcb','tcw'), spatial_agg = c(1,2), temporal_agg = c(8, 16, 30),
                        year_start = 2001, year_end = 2016, sensor = 'MODIS', prefix = 'MCD43A4', stringsAsFactors = F)
setDT(brdf_vars)
brdf_vars[, variables := paste(var_base, spatial_agg, temporal_agg, sep = '_')]
brdf_vars[, calc_time := T]

viirs_vars = expand.grid(product = 'VCMCFG', version = '01', variables = 'avg_rad',
                                     year_start = 2012, year_end = 2016, sensor = 'VIIRS', prefix = 'VCMCFG', calc_time = F, stringsAsFactors = F)

srtm_vars = expand.grid(product = 'srtm', variables = c('aspect', 'roughness', 'slope','TPI','TRI', 'elevation'), version = '01', year_start = 2000, year_end = 2000,
                        sensor = 'srtm', prefix = 'srtm', stringsAsFactors = F)

# 
# setDT(dat)

#create a master list of files
rasfiles = rbindlist(list(lst_vars, vis_vars, brdf_bands, brdf_vars, viirs_vars, srtm_vars), fill = T)
# rasfiles[, rasname:= paste0(paste(..city,product,version,variables,year_start,year_end,sep='_'),'.tif')]
# rasfiles[, raspath := file.path(out.dir,prefix, 'latlong', rasname)]
rasfiles[, id:= .I]

summary_grid = expand.grid(funk = c('mean','median','min','max', ""), time = c('mth_yr', 'mth', 'yr', 'synoptic'), 
                           id = unique(rasfiles[,id]), city = listofcities, stringsAsFactors = F) #'mth','yr',
setDT(summary_grid)
summary_grid[funk == "", time := ""]
summary_grid = unique(summary_grid)

summary_grid = merge(summary_grid, rasfiles, by = 'id')
summary_grid[, rasname:= paste0(paste(city,product,version,variables,year_start,year_end,sep='_'),'.tif')]
summary_grid[funk == "", raspath := file.path(out.dir,prefix, 'latlong', rasname)]

summary_grid = summary_grid[!(funk != "" & prefix == 'srtm'), ]
summary_grid[funk != "", rasname := paste0(tools::file_path_sans_ext(basename(rasname)), '_', time, '_',funk, '.tif') ]
summary_grid[funk != "", raspath:=  file.path(out.dir, '/summary/',product, time, funk, rasname)]

meta_report = rbindlist(lapply(summary_grid[, raspath], metadata_report))

meta_report[, rasname := (basename(as.character(path)))]

meta_report = merge(meta_report, summary_grid, by = 'rasname')

meta_report = meta_report[, .(rasname, x, y, z, ncell, mis_cell, frac_mis, summary_function = funk, city, product, year_start, year_end, spatial_agg, temporal_agg)]

saveRDS(meta_report, '/media/dan/meta_report.rds')
write.csv(meta_report, '/media/dan/meta_report.csv', row.names = F)

# 
# 
# for(line in 1:nrow(dat)){
#   
#   metadata = dat[line,]
#   print(metadata)
#   
#   #load the dates
#   sss = metadata[, sensor ]
#   
#   if(sss == 'VIIRS'){
#     namepath = file.path(layerfolder, 'NOAA_VIIRS_DNB_MONTHLY_V1_VCMCFG.txt')
#   }else{
#     namepath = file.path(layerfolder, paste0(sss,ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
#     
#   }
#   
#   nnn = read.delim(namepath, header = F, stringsAsFactors = F)[,1]
#   
#   if(!all(grepl('_', nnn, fixed = T))){
#     nnn = paste(substr(nnn, 1,4), substr(nnn, 5,6), substr(nnn, 7,8), sep = '_')
#   }
#   
#   #convert to date paths
#   nnn = as.Date(nnn, '%Y_%m_%d')
#   
#   if(metadata[, calc_time]){
#     nnn = get_layer_date(nnn, metadata[,temporal_agg])
#   }
#   
#   
#   #classify into monthly
#   mth = month(nnn)
#   yr = year(nnn)
#   mth_yr = paste0(yr,'_',sprintf("%02d", mth))
#   synoptic = rep(1, length(mth))
#   
#   #load the raster
#   for(city in listofcities){
#     rasname = paste0(metadata[, paste(..city,product,version,variables,year_start,year_end,sep='_')],'.tif')
#     ras = readAll(brick(file.path(out.dir,metadata[,prefix], 'latlong', rasname)))
#     
#     #get the data on the observed/raw(ish) information
#     
#     for(sg in 1:nrow(summary_grid)){
#       newname = paste0(tools::file_path_sans_ext(basename(rasname)), '_', summary_grid[sg, time], '_',summary_grid[sg, funk], '.tif')
#       newpath = file.path(out.dir, '/summary/',metadata[,product], summary_grid[sg, time], summary_grid[sg, funk], newname)
#     }
#   
#   }
# }
