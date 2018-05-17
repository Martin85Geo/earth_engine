library('googledrive')
library('data.table')

overwrite = T

#a list of all files in modis folder-- since I can't figure out how to get ee to save to sub folders
modis_files = drive_ls(path = 'modis')

#reorganize files into the following path
#earth_engine/product_name/city
mods = modis_files
setDT(mods)

#keep only the most recent version of the file
last_modified = unlist(lapply(mods$drive_resource, function(x) x$modifiedTime))
mods[, date_modified := last_modified]
mods[, mody := max(date_modified), by = 'name']
mods = mods[date_modified == mody,]

#create some useful variables
mods[, c('city', 'product_name'):=tstrsplit(name,split = '_', fixed = T, keep = c(1,2))]
mods[, variable:= substr(name, nchar(paste(city,product_name))+2, nchar(name) - 9)]

#some of the surface reflectance is weird and has addition _[0-9] as a suffix. Remove these for now
weird_files = mods[grepl('sur_refl', variable, fixed = T) & substr(variable, nchar(variable)-1,nchar(variable)-1)=='_',]

mods = mods[!id %in% weird_files[,id]]
mods[,new_path:=paste0('/media/dan/earth_engine/',product_name,'/', city,'/')]

#create folder structure
pos_paths = unique(mods$new_path)
pos_paths = pos_paths[!dir.exists(pos_paths)]
for(ppp in pos_paths) dir.create(ppp, recursive = T)

#download files
fff = mods[product_name == 'MCD43A4',]
if(!overwrite){
  fff[!file.exists(paste0(fff$new_path,fff$name))]
}

if(nrow(fff)>0){
  for(img in 1:nrow(fff)){
    drive_download(as_id(fff$id[img]), path = paste0(paste0(fff$new_path[img],fff$name[img])), overwrite = T)
  }
}

