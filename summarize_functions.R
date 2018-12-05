get_layer_date = function(dates, temporal_composite = 8){
  x = split(dates, ceiling(seq_along(dates)/temporal_composite))
  x = do.call(c,lapply(x,mean))
  return(x)
}

summarize_variable = function(ras, classification, summary_fun = mean, na.rm = T){
  
  #calculate summary
  res = lapply(sort(unique(classification)), function(x){
    
    a = ras[[which(classification == x)]]
    if(nlayers(a) > 1){
    
      res = calc(a, summary_fun, na.rm = na.rm)
    }else{
      res = a
    }
    
  })
  
  #brick and ship
  res = brick(res)
  
  return(res)
}

lower = function(x, ...) quantile(x, probs = .025, ...)
upper = function(x, ...) quantile(x, probs = .975, ...)