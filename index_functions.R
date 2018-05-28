#' Calculate a normalized differenced index
#' 
#' @param band1 Raster*.
#' @param band2 Raster.
#' 
#' This function calculates an ND-Index of the form of (band1 - band2)/(band1 + band2)
#' 
nd_index = function(band1, band2){
  
  return((band1 - band2)/(band1 + band2))
  
}

#'Create a normalized differenced index, while aggregating the source rasters
#'
#'This function calculates an ND-Index of the form of (band1 - band2)/(band1 + band2)
#'
#'@param band1 Raster*.
#'@param band2 Raster*. 
#'@param fact numeric. See raster::aggregate for details 
#'@param agg_fun function. See raster::aggregate
#'@return An aggregated raster brick
#'
spacetime_aggregate_nd = function(band1, band2, fact = c(1,1,1), agg_fun = mean){
  
  #make sure the dimensions are the same
  stopifnot(dim(band1) == dim(band2))
  
  #aggregate the bands
  if(any(fact > 1)){
    band1 = aggregate(band1, fact = fact, fun = agg_fun)
    band2 = aggregate(band2, fact = fact, fun = agg_fun)
  }
  
  #create the index
  index = nd_index(band1, band2)
  
  return(index)
}

#' Helper function to load brdf rasters after QA processing
#' 
#' @param datafolder file_path/character. parent folder of the files
#' @param spectrum character. One of red, green, blue, nir, swir1, swir2, and swir3
#' @param city character. name of the city to load
#' @param projected logical. Should the latlong or sinosoidal projection be used
#' @param force_in_memory logical. Read such that the raster package loads everything into memory
#' 
#' rasname = paste0(x, '_',brdf[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
load_brdf_raster = function(datafolder, spectrum = c('red', 'nir','blue','green','swir1','swir2','swir3'), city, projected = T, force_in_memory = T){
  
  #create the spectrum to band mapping
  bands = 1:7
  names(bands) = c('red', 'nir','blue','green','swir1','swir2','swir3')
  
  band = bands[match.arg(spectrum)]
  
  rasname = paste(city, 'MCD43A4', '006','Nadir', 'Reflectance',paste0('Band',band),'2001','2016.tif', sep = '_')
  print(file.path(datafolder, rasname))
  bla = brick(file.path(datafolder, rasname))
  
  if(!inMemory(bla) & force_in_memory){
    bla = readAll(bla)
  }
  
  return(bla)
}