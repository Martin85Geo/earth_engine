metadata_report = function(raspath){
  ras = readAll(brick(raspath))
  
  report = data.frame(path = raspath,
                      x = dim(ras)[1],
                      y = dim(ras)[2],
                      z = nlayers(ras),
                      ncell = ncell(ras),
                      mis_cell = sum(is.na(ras[])))
  
  return(report)
  
  
}