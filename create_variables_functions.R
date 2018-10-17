create_ndwi = function(params){
  
  swir = load_brdf_raster(datafolder = datadir,spectrum = 'green',city = params$city)
  nir = load_brdf_raster(datafolder = datadir,spectrum = 'nir',city = params$city)
  res = spacetime_aggregate_nd(nir, swir, fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg))
  
  #save raster
  rasname = paste0('ndwi_nirswi_', paste(params, collapse = "_"), '.tif')
  raspath = file.path(ooot,rasname)
  
  writeRaster(res, raspath, overwrite = T)
  
  return(rasname)
}


create_ndvi = function(params){
  
  red = load_brdf_raster(datafolder = datadir,spectrum = 'red', city = params$city)
  nir = load_brdf_raster(datafolder = datadir,spectrum = 'nir',city = params$city)
  res = spacetime_aggregate_nd(nir, red, fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg))
  
  #save raster
  rasname = paste0('ndvi_', paste(params, collapse = "_"), '.tif')
  raspath = file.path(ooot,rasname)
  
  writeRaster(res, raspath, overwrite = T)
  
  return(rasname)
}

#https://en.wikipedia.org/wiki/Enhanced_vegetation_index
create_evi = function(params){
  
  blue = load_brdf_raster(datafolder = datadir,spectrum = 'blue', city = params$city)
  red = load_brdf_raster(datafolder = datadir,spectrum = 'red', city = params$city)
  nir = load_brdf_raster(datafolder = datadir,spectrum = 'nir',city = params$city)
  
  fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg)
  
  #aggregate the variables
  if(any(fact > 1)){
    blue = aggregate(blue, fact = fact, fun = mean)
    red = aggregate(red, fact = fact, fun = mean)
    nir = aggregate(nir, fact = fact, fun = mean)
  }
  
  G = 2.5
  C1 = 6
  C2 = 7.5
  L = 1
  
  num = nir - red
  denom = nir + C1 * red - C2 * blue + L
  res = G*num/denom
  rm(num); rm(denom);
  
  #save raster
  rasname = paste0('evi_', paste(params, collapse = "_"), '.tif')
  raspath = file.path(ooot,rasname)
  
  writeRaster(res, raspath, overwrite = T)
  
  return(rasname)
}

create_tcb = function(params){
  
  bands = lapply(c('red', 'nir','blue','green','nir2','swir1','swir2'), function(x) load_brdf_raster(datadir, x, city = params$city))
  fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg)
  #aggregate the variables
  if(any(fact > 1)){
    bands = lapply(bands, function(x) aggregate(x, fact = fact, fun = mean))
  }
  
  redc = .4395
  nir1c = .5945
  bluec = .246
  greenc = .3918
  nir2c = .3506
  swir1c = .2136
  swir2c = .2678
  coefs = c(redc, nir1c, bluec,greenc,nir2c, swir1c,swir2c)
  
  bands = lapply(1:length(bands), function(x) bands[[x]] * coefs[x])
  
  bands = Reduce('+', bands)
  
  #save raster
  rasname = paste0('tcb_', paste(params, collapse = "_"), '.tif')
  raspath = file.path(ooot,rasname)
  
  writeRaster(bands, raspath, overwrite = T)
  
  return(rasname)
}

create_tcw = function(params){
  
  bands = lapply(c('red', 'nir','blue','green','nir2','swir1','swir2'), function(x) load_brdf_raster(datadir, x, city = params$city))
  fact = c(params$spatial_agg, params$spatial_agg, params$temporal_agg)
  #aggregate the variables
  if(any(fact > 1)){
    bands = lapply(bands, function(x) aggregate(x, fact = fact, fun = mean))
  }
  
  redc = .1147
  nir1c = .2489
  bluec = .2408
  greenc = .3132
  nir2c = -.3122
  swir1c = -.6416
  swir2c = -.5087
  
  coefs = c(redc, nir1c, bluec,greenc,nir2c, swir1c,swir2c)
  
  bands = lapply(1:length(bands), function(x) bands[[x]] * coefs[x])
  
  bands = Reduce('+', bands)
  
  #save raster
  rasname = paste0('tcw_', paste(params, collapse = "_"), '.tif')
  raspath = file.path(ooot,rasname)
  
  writeRaster(bands, raspath, overwrite = T)
  
  return(rasname)
}
