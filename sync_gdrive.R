library('googledrive')

overwrite_files = T
base_path = '/media/dan/earth_engine/'
#compare google drive vs. on disk
drive_folders = drive_ls(path = '~/earth_engine/')

drive_folders = drive_folders[drive_folders$name=='MCD43A4',]

#for each folder
for(i in 1:nrow(drive_folders)){
  #get files from drive
  fff = drive_ls(paste0('~/earth_engine/', drive_folders[i,'name']), pattern = '\\.tif',recursive = T)
  #get files from disk
  ondisk = basename(list.files(path = paste0(base_path, drive_folders[i,'name']), recursive = T))
  
  #subset out files already downloaded
  if(!overwrite_files){
    fff = fff[!fff$name %in% ondisk,]
  }
  
  #check if the image already exists, if not download
  if(nrow(fff)>0){
    for(img in 1:nrow(fff)){
      
      #get folder path
      city = strsplit(fff$name[img],split = '_',fixed = T)[[1]][1]
      ootpoot = file.path(base_path,drive_folders$name[i], city)
      dir.create(ootpoot, recursive = T)
      
      drive_download(as_id(fff$id[img]), path = paste0(ootpoot, '/',fff$name[img]), overwrite = T)
      
      #Sys.sleep(1)
    }
  }
  
}

disk_files = list.files(path = '/media/dan/earth_engine/',recursive = T)
