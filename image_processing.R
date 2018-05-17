#'A function to combine google earth outputs into a tif brick
#'
#' @param datafolder file path. Location of the tifs from GEE
#' @param layerfolder file_path. Location of the .txt files specifying layer names from GEE
#' @param metadata data.table. Single row data table used to govern the processing of images
#' @param qa_info numeric vector. List of values in the QA layer denoting a good pixel
#' @param location_names character vector. List of ROIs/cities
#' 
#' @import data.table
#' 
stich_image = function(datafolder, layerfolder, metadata, qa_info = NULL, location_name =""){
  
  message(location_name)
  
  if(grepl(' ', location_name, fixed = T)){
    warning('Removing spaces from location name')
    location_name = gsub(pattern = ' ', '', x = location_name, fixed = T)
  }
  
  #brick all the data images together
  yst = metadata[,year_start]
  ynd = metadata[,year_end]
  #/datafolder/product/location/file.ext
  dras = file.path(datafolder,metadata[,product],location_name,
                   paste0(location_name, '_',metadata[,product],'_',metadata[,variables],'_',yst:ynd,'.tif'))
  
  #load the first raster in memory to 
  template = brick(dras[1])[[1]]
  
  #load as a list of arrays
  dras = lapply(dras, function(x) as.array(raster::brick(x)))
  
  #preserve the number of years and their dimensions
  dras_meta = lapply(dras, dim)

  #brick all the qa layers together
  qras = file.path(datafolder,metadata[,qa_product],location_name,
                   paste0(location_name, '_',metadata[,qa_product],'_',metadata[,qa_layer],'_',yst:ynd,'.tif'))
  
  qras = lapply(qras, function(x) as.array(raster::brick(x)))
  qras_meta = lapply(qras, dim)
  
  #convert both dras and qras to vectors
  dras = unlist(dras)
  qras = unlist(qras)
  
  #get unique qa vals
  allqavals = unique(as.vector(qras))
  allqavals = allqavals[!is.na(allqavals) & allqavals != metadata$qa_na]
  
  
  #generate good_qa_values
  good_qa_vals = get_qa_values(allqavals, bit_interpreter = qa_info[[1]], logic = qa_info[[2]], nbits = qa_info[[3]])
  
  #Anything that did not pass QA muster gets set to N
  dras[!qras %in% good_qa_vals] = NA
  
  #remove qras
  rm(qras)
  
  #enforce pixel bounds and scale
  dras[dras<metadata[,lower] | dras>metadata[,upper]] = NA
  dras = dras * metadata[,scale]
  
  #convert back to raster brick
  #probably not the most effective way, but whatever
  #calculate the number of layers required
  nlay = sum(sapply(dras_meta, '[[',3))
  
  #remake dras into an array
  dras = array(dras, dim = c(dim(template)[1:2], nlay))
  dras = brick(dras, crs = crs(template))
  
  #sort out names
  namepath = file.path(layerfolder, paste0(metadata[,sensor],ifelse(nchar(metadata[,version])>0, paste0('_',metadata[,version],'_'), "_"), metadata[,product],'.txt'))
  nnn = read.delim(namepath, header = F, stringsAsFactors = F)[,1]
  
  new_names = paste0(location_name, '_', nnn)
  names(dras) = new_names
  #return brick
  return(dras)
  
}
