library('googledrive')
library('data.table')
#a list of all files in modis
modis_files = drive_ls(path = 'modis')

#reorganize files into the following path
#earth_engine/product_name/city
mods = as.data.table(modis_files[,1:2])
mods[, c('city', 'product_name'):=tstrsplit(name,split = '_', fixed = T, keep = c(1,2))]
mods[, variable:= substr(name, nchar(paste(city,product_name))+2, nchar(name) - 9)]

#some of the surface reflectance is weird and has addition _[0-9] as a suffix. Remove these for now
weird_files = mods[grepl('sur_refl', variable, fixed = T) & substr(variable, nchar(variable)-1,nchar(variable)-1)=='_',]

mods = mods[!id %in% weird_files[,id]]
mods[,new_path:=paste0('earth_engine/',product_name,'/', city,'/')]


#create the new folder structure
existing_folder = drive_ls('~/earth_engine', type = 'folder', recursive = T)
for(pn in unique(mods[,product_name])){

  drive_mkdir(paste0('~/earth_engine/',pn,'/'))

  for(cit in unique(mods[,city])){
    drive_mkdir(paste0('~/earth_engine/',pn,'/',cit,'/'))
  }
}

#Move the things
iter = 1
for(i in 1:nrow(mods)){
  drive_mv(as_id(mods[i,id]), mods[i,new_path], verbose = F)
  iter = iter + 1
  
  if(iter %% 9 == 0){
    Sys.sleep(1.1)
  }
  
  if(iter %% 100 == 0){
    print(iter)
  }
  
}

