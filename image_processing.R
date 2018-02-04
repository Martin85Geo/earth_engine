#'A function to combine google earth outputs into a tif brick
#'
#' @param datafolder file path. Location of the tifs from GEE
#' @param layerfolder file_path. Location of the .txt files specifying layer names from GEE
#' @param metadata data.table. Single row data table used to govern the processing of images
#' @param good_qa_vals numeric vector. List of values in the QA layer denoting a good pixel
stich_image = function(datafolder, layerfolder, metadata, good_qa_vals = NULL){
  
  #brick all the data images together
  
  #brick all the qa layers together
  
  #make a qa mask
  
  #enforce pixel range and scaling
  
  #return brick
  
}