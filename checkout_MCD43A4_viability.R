library('data.table')
library('sf')
library('raster')
library('ggplot2')

code.dir = '/home/dan/Documents/code/earth_engine/'
out.dir = '/media/dan/ee_res/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))
city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)


metadata = expand.grid(product = unique(brdf$product), location_name = listofcities,
                        variables = unique(brdf$variables), year = 2001:2016, stringsAsFactors = F)

#fix name
metadata$location_name = gsub(' ', '', metadata$location_name, fixed = T)

setDT(metadata)
metadata[, qa_layer := paste0('BRDF_Albedo_Band_Mandatory_Quality',substr(variables, nchar(variables) - 5, nchar(variables)))]

#only keep band 4
metadata = metadata[grepl('Band4', qa_layer),]

#Create a list of files
dras = file.path('/media/dan/earth_engine',metadata[,product],metadata[,location_name],
                 paste0(metadata[,location_name], '_',metadata[,product],'_',metadata[,variables],'_',metadata[,year],'.tif'))

qras = file.path('/media/dan/earth_engine',metadata[,product],metadata[,location_name],
                 paste0(metadata[,location_name], '_',metadata[,product],'_',metadata[,qa_layer],'_',metadata[,year],'.tif'))

check_ras = function(x){
  #for each layer get the fraction of cells that are not 0 or NA
  rrr = stack(x)
  tabs = lapply(1:nlayers(rrr), function(y) {
    aaa = table(rrr[[y]][], useNA = 'ifany')
    aaa = data.table(aaa)
    aaa[, id := y]
    })
  
  tabs =rbindlist(tabs)
  tabs[, layer := x]
  
  return(tabs)
  
}

#get stats
good_px_finder = parallel::mclapply(qras, check_ras, mc.cores = 6)
saveRDS(good_px_finder,'/media/dan/temp/good_px_finder_b4_brdf.rds')

px = rbindlist(good_px_finder)

px[, base := basename(layer)]
px[, c('City', 'Product', 'Year'):=tstrsplit(base, '_', fixed= T, keep = c(1,2,9))]
px[, Year:=as.numeric(substr(Year, 1, 4))]

#count number of total cells by city
cells_per_city = px[id == 1 & Year ==2004, .(total_cells = sum(N)), by = 'City']

#for each day + city, count the number of good cells (e.g QA is 0)
#start by getting each unique city day
uniq_cd = unique(px[,.(City, Year, id)])
good_px = merge(uniq_cd, px[V1 == 0, .(City, Year,id, N)], all.x = T)

#merge on total number of pixels
good_px = merge(good_px, cells_per_city, all.x = T, by = 'City')

#create a semi artifical date indicator
good_px[, date:= Year + (id/366)]

#calc percent good px
good_px[is.na(N), N := 0]
good_px[, perc_good := N/total_cells]

pdf('/media/dan/graphics/brdf_good_cell_plots.pdf', height = 10, width = 10)
for(cit in unique(good_px$City)){
  pdat = good_px[City == cit,]
  
  g = ggplot(pdat, aes(x = date, y = perc_good)) + geom_line() + ylim(0,max(pdat$perc_good)) + theme_bw() +
    xlab('Date') + ylab('Percent Good Cells BRDF Band4') + ggtitle(cit)
  
  plot(g)
  
}
dev.off()

#Make it any non NA cells
ok_px = merge(uniq_cd, px[V1 != -9999, list(N = sum(N)) ,by = c('City', 'Year','id')], all.x = T)

#merge on total number of pixels
ok_px = merge(ok_px, cells_per_city, all.x = T, by = 'City')

#create a semi artifical date indicator
ok_px[, date:= Year + (id/366)]

#calc percent good px
ok_px[is.na(N), N := 0]
ok_px[, perc_good := N/total_cells]

pdf('/media/dan/graphics/brdf_goodorok_cell_plots.pdf', height = 10, width = 10)
for(cit in unique(good_px$City)){
  pdat = ok_px[City == cit,]
  
  g = ggplot(pdat, aes(x = date, y = perc_good)) + geom_line() + ylim(0,max(pdat$perc_good)) + theme_bw() +
    xlab('Date') + ylab('Percent Non NA Cells') + ggtitle(cit)
  
  plot(g)
  
}
dev.off()

