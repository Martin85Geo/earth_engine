#A function to load a raster into memory and assign the dates as the object names
load_brick = function(ras, dates){
  
  #load the dates-- and assume length 1 character vector is a file path
  if(class(dates) == 'character' & length(dates)==1){
    ddd = read.delim(dates, stringsAsFactors = F,header = F)[,1]
  }else{
    ddd = dates
  }
  
  #load the raster brick
  bbb = readAll(brick(ras))
  
  stopifnot(nlayers(bbb) == length(ddd))
  
  names(bbb) = ddd
  
  return(bbb)
  
}

#stolen from bfastts
create_ts = function(vals, dates, obs_year){
  z <- zoo(vals, dates)
  yr <- as.numeric(format(time(z), "%Y"))
  jul <- as.numeric(format(time(z), "%j"))
  delta <- min(unlist(tapply(jul, yr, diff)))
  zz <- aggregate(z, yr + (jul - 1)/delta/obs_year)
  return(as.ts(zz))
}

bfast_pixel = function(index, image, dates, obs_year = 23, na_thresh = .1, h = .15, nbrk = 100, return_model = F, iter = 40){
  start = Sys.time()
  print(paste('Start', index, start))
  #collect results
  res = data.table(index = index)
  
  #create the time series object
  ttt = create_ts(as.numeric(image[index]), dates, obs_year)
  
  if(sum(is.na(ttt))/length(ttt) > na_thresh){
    res = data.table(index = index, note = 'Too Many NAs')
  } else{
    #fill in nas
    ttt = na.approx(ttt)
    
    #run bfast
    bbb = bfast(ttt, h = h, season = 'harmonic', max.iter = iter, breaks = nbrk )
    
    out = bbb$output[[length(bbb$output)]]
    
    if(!is.na(out$bp.Vt[1])){
      res[, num_bp_vt:= length(out$bp.Vt$breakpoints)]
      for(i in 1:length(out$bp.Vt$breakpoints)){
        res[, paste0(c('m_', 'l_','u_'),i) := lapply(out$ci.Vt$confint[i,], function(x) x)]
        res[, paste0('mag_', i) := bbb$Mags[i,3]]
      }
    }
    
  }
  
  #store run parameters and return
  res[, c('na_thresh', 'h', 'nbrk'):= list(na_thresh, h, nbrk)]
  
  end = Sys.time()
  
  res[, start:= start]
  res[, end := end]
  
  print(paste('End', index, end))
  
  
  if(return_model){
    if(!exists('bbb')){
      bbb = list()
    }
    return(list(res, bbb))
    
  }else{
    return(res)
  }
  
}
