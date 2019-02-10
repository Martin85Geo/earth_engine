library('sf')
library('data.table')

fff = list.files('/home/dan/Documents/react_data/Cities_React/')
fff = data.table(fff = fff)
fff[, file_ext := tools::file_ext(fff)]
fff = fff[file_ext == 'shp',]
fff = fff[grepl('SA_Polygon', fff, fixed = T),]
fff[, city := tstrsplit(fff, split ="_", keep = 1)]


#load the shapes

shps = lapply(paste0('/home/dan/Documents/react_data/Cities_React/', fff[,fff]), function(x) st_read(x, stringsAsFactors = F))

shps = do.call(rbind, shps)

shps$Name = fff[, city]

#old version
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp", stringsAsFactors = F)

if(is.null(city_shape$old_name)){
  city_shape$old_name = city_shape$Name
}

cw = st_intersection(shps, city_shape[,'old_name'])

st_geometry(cw) = NULL

shps = merge(shps, cw[, c('Name', 'old_name')], by = 'Name', all.x  = T)

#st_write(shps, "/home/dan/Documents/react_data/Cities_React/study_areas.shp", delete_dsn = T)


#bulk renaming
if(!all(shps$Name == shps$old_name)){
  
  code.dir = '/home/dan/Documents/code/earth_engine/'
  out.dir = '/media/dan/ee_processed/'
  
  for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R', 'index_functions.R', 'summarize_functions.R',
               'metadata_functions.R')) source(paste0(code.dir,ddd))
  city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
  listofcities = as.character(city_shape$old_name)
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
  
  st_geometry(city_shape) = NULL
  sg = merge(summary_grid, city_shape, by.x = 'city', by.y = 'old_name', all.x = T)
  
  #fix all the names
  sg[ ,newpath := stringi::stri_replace_all_fixed(raspath, city, Name)]
  sg[ ,newpath := stringi::stri_replace_all_fixed(newpath, 'ee_processed', 'processed')]
  
  # #for each row, make folder, copy into new path
  # for(i in 1:nrow(sg)){
  #   dir.create(dirname(sg[i,newpath]), recursive = T)
  #   file.copy(sg[i, raspath], sg[i,newpath])
  # }
  # 
  cw = unique(sg[,.(city,Name)])
  #do base files
  basefiles = list.files('/media/dan/earth_engine/',recursive = T,full.names = T)
  bf = data.table(a =basefiles)
  bf = bf[tools::file_ext(a) == 'tif',]
  bf[, chg:= 0]
  for(d in 1:nrow(cw)){
    bf[chg ==0 & grepl(cw[d,city],a), b:= stringi::stri_replace_all_fixed(a, cw[d,city], cw[d,Name])]
    bf[a!=b, chg := 1]
  }
  
  bf[,b :=stringi::stri_replace_all_fixed(b, 'earth_engine', 'ee_dl')]
  
  for(i in 1:nrow(bf)){
    dir.create(dirname(bf[i,b]), recursive = T)
    file.copy(bf[i, a], bf[i,b])
  }
  
}

