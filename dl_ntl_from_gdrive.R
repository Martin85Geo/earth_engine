library('googledrive')
library('data.table')

overwrite = T

#a list of all files in modis folder-- since I can't figure out how to get ee to save to sub folders
files = drive_ls(path = 'modis', pattern = 'NIGHTTIME')

#reorganize files into the following path
#earth_engine/product_name/city
mods = files
setDT(mods)

#keep only the most recent version of the file
last_modified = unlist(lapply(mods$drive_resource, function(x) x$modifiedTime))
mods[, date_modified := last_modified]
mods[, mody := max(date_modified), by = 'name']
mods = mods[date_modified == mody,]

#create some useful variables
mods[, c('city'):=tstrsplit(name,split = '_', fixed = T, keep = c(1))]
mods[, variable:= substr(name, nchar(paste(city,'NIGHTTIME_LIGHTS'))+2, nchar(name) - 9)]
mods[, product_name := 'NIGHTTIME_LIGHTS']

mods[,new_path:=paste0('/media/dan/earth_engine/',product_name,'/', city,'/')]

#create folder structure
pos_paths = unique(mods$new_path)
pos_paths = pos_paths[!dir.exists(pos_paths)]
for(ppp in pos_paths) dir.create(ppp, recursive = T)

#download files
fff = mods
if(!overwrite){
  fff[!file.exists(paste0(fff$new_path,fff$name))]
}

if(nrow(fff)>0){
  for(img in 1:nrow(fff)){
    drive_download(as_id(fff$id[img]), path = paste0(paste0(fff$new_path[img],fff$name[img])), overwrite = T)
  }
}

