#'A function to combine google earth outputs into a tif brick
#'
#' @param datafolder file path. Location of the tifs from GEE
#' @param layerfolder file_path. Location of the .txt files specifying layer names from GEE
#' @param metadata data.table. Single row data table used to govern the processing of images
#' @param good_qa_vals numeric vector. List of values in the QA layer denoting a good pixel
#' @param location_names character vector. List of ROIs/cities
#' 
#' @import data.table
#' 
stich_image = function(datafolder, layerfolder, metadata, good_qa_vals = NULL, location_name =""){
  
  message(location_name)
  
  if(grepl(' ', location_name, fixed = T)){
    warning('Removing spaces from location name')
    location_name = gsub(pattern = ' ', '', x = location_name, fixed = T)
  }
  
  #brick all the data images together
  yst = metadata[,year_start]
  ynd = metadata[,year_end]
  dras = file.path(datafolder,paste0(location_name, '_',metadata[,product],'_',metadata[,variables],'_',yst:ynd,'.tif'))
  dras = raster::brick(lapply(dras, raster::brick))
  
  #brick all the qa layers together
  qras = file.path(datafolder,paste0(location_name, '_',metadata[,product],'_',metadata[,qa_layer],'_',yst:ynd,'.tif'))
  qras = raster::brick(lapply(qras, raster::brick))
  
  #mask for qa
  allqavals = unique(qras)
  navals = allqavals[!allqavals %in% good_qa_vals]
  
  #set NoData values for qa
  qras[qras==metadata[,qa_na]] = NA
  
  #make this next step faster
  qras = raster::reclassify(qras,cbind(navals, NA))
  qras[!is.na(qras)] = 1
  
  dras = dras * qras
  #enforce pixel range and scaling
  dras[dras<metadata[,lower] | dras>metadata[,upper]] = NA
  
  dras = dras * metadata[,scale]
  
  #sort out names
  namepath = file.path(layerfolder, paste0(metadata[,sensor],ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
  nnn = read.delim(namepath, header = F)[[1]]
  
  names(dras) = paste0(location_name, '_', nnn)
  
  #return brick
  return(dras)
  
}
