#Libs
library('sf')
library('data.table')
library('googledrive')
library('raster')

code.dir = '/home/dan/Documents/code/earth_engine/'
out.dir = '/media/dan/ee_res/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))

rasterOptions(maxmemory = 2e9, chunksize = 2e8)


#process lst
# lst[, id:=.I]
# for(i in lst[product %in% c('MOD11A2'),id]){
# 
#   lapply(listofcities, function(x){
# 
#     lst_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                          layerfolder = '/media/dan/earth_engine/',
#                          metadata = lst[id == i,],
#                          qa_info = build_lst_qa(),
#                          location_name = x)
# 
#     rasname = paste0(x, '_',lst[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
#     
#     #native projection
#     raster::writeRaster(x = lst_ras,filename = file.path(out.dir, paste0('unproj_',rasname)), overwrite = T )
#     
#     #project to latlong
#     ras = projectRaster(lst_ras, crs = as.character(st_crs(city_shape)[2]))
#     raster::writeRaster(x = ras,filename = file.path(out.dir, rasname), overwrite = T )
#     return(invisible())
#   })
# 
# }

#DO vegi indices
# vis[,id:=.I]
# for(i in vis[product %in% c('MOD13A1'),id]){
#   
#   lapply(listofcities, function(x){
#     
#     vis_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                           layerfolder = '/media/dan/earth_engine/',
#                           metadata = vis[id == i,],
#                           qa_info = build_lst_qa(),
#                           location_name = x)
#     
#     rasname = paste0(x, '_',vis[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
#     
#     #native projection
#     raster::writeRaster(x = vis_ras,filename = file.path(out.dir, paste0('unproj_',rasname)), overwrite = T )
#     
#     
#     #project to latlong
#     ras = projectRaster(vis_ras, crs = as.character(st_crs(city_shape)[2]))
#     raster::writeRaster(x = ras,filename = file.path(out.dir, rasname), overwrite = T )
#     return(invisible())
#   })
#   
# }

#DO reflectance
# reflect[,id:=.I]
# for(i in reflect[,id]){
#   
#   lapply(listofcities, function(x){
#     
#     ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                           layerfolder = '/media/dan/earth_engine/',
#                           metadata = reflect[id == i,],
#                           qa_info = build_ref_qa(i),
#                           location_name = x)
#     
#     rasname = paste0(x, '_',reflect[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
#     
#     #native projection
#     raster::writeRaster(x = ref_ras,filename = file.path(out.dir, paste0('unproj_',rasname)), overwrite = T )
#     
#     
#     #project to latlong
#     ras = projectRaster(ref_ras, crs = as.character(st_crs(city_shape)[2]))
#     raster::writeRaster(x = ras,filename = file.path(out.dir, rasname), overwrite = T )
#     return(invisible())
#   })
#   
# }

albedo[,id:=.I]
for(i in albedo[,id]){
  
  lapply(listofcities, function(x){
    
    ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
                          layerfolder = '/media/dan/earth_engine/',
                          metadata = albedo[id == i,],
                          qa_info = build_albedobrdf_qa(),
                          location_name = x)
    
    rasname = paste0(x, '_',albedo[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
    
    #native projection
    raster::writeRaster(x = ref_ras,filename = file.path(out.dir, paste0('unproj_',rasname)), overwrite = T )
    
    
    #project to latlong
    ras = projectRaster(ref_ras, crs = as.character(st_crs(city_shape)[2]))
    raster::writeRaster(x = ras,filename = file.path(out.dir, rasname), overwrite = T )
    return(invisible())
  })
  
}
