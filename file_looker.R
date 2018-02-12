library('raster')
library('data.table')
extent_shapefile_path = '/home/dan/Documents/react_data/Cities_React/Boundaries.shp'
modis_product = 'MODIS/006/MYD11A2'
product = 'MYD11A2'
start_year = 2004
end_year = 2016
end_year = end_year + 1 #because how range works
variables = c('LST_Night_1km', 'LST_Day_1km', 'QC_Day', 'QC_Night') #c('sur_refl_b01','sur_refl_b02', 'sur_refl_b03', 'sur_refl_b04','sur_refl_b05','sur_refl_b06','sur_refl_b07','QA','StateQA')
target_crs = 'SR-ORG:6974'

blah = shapefile(extent_shapefile_path)
fff = setDT(expand.grid(loc = blah$Name, yyy = 2004:2016, vars = variables, stringsAsFactors = F))
fff[, loc := gsub(pattern = " ",replacement = "", loc, fixed = T)]
#[dlpath + c[1].replace(' ','') + "_" + product +'_'+c[0]+'_'+str(c[2]) +'.tif'
fff[,fpath:= paste0('/modis/',loc, '_', product, '_', vars, '_', yyy, '.tif')]

#load the files in gdrive
txt = read.table('/media/dan/googledrive/modis_filelist_27.txt', sep = '\n')
setDT(txt)

txt[,paste0('a',1:3):= tstrsplit(V1, '_', fixed =T, keep= 1:3)]

table(fff[,fpath] %in% txt$V1)

blah =paste0('/modis/',list.files('/media/dan/googledrive/gdrive/modis/'))


