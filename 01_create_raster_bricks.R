#Libs
library('sp')
library('sf')
library('data.table')
library('googledrive')
library('raster')
library('foreach')
library('doParallel')

code.dir = '/home/dan/Documents/code/earth_engine/'
out.dir = '/media/dan/ee_processed/'
for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

expand.grid.df <- function(...) Reduce(function(...) merge(..., by=NULL), list(...))
rasterOptions(maxmemory = 2e9, chunksize = 2e8)

process_product = function(dat, prefix, out.dir, over, qa_funk){
  
  #create file structure
  dir.create(file.path(out.dir, prefix, '/unproj/'), recursive = T)
  dir.create(file.path(out.dir, prefix, '/latlong/'), recursive = T)
  
  #Make the rasters
  for(i in 1:nrow(dat)){
    print(dat[i,])
    foreach(x=over) %dopar% {
      ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
                            layerfolder = '/media/dan/earth_engine/',
                            metadata = dat[i,],
                            qa_info = qa_funk(), 
                            location_name = x)
      
      rasname = paste0(x, '_',dat[i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
      raster::writeRaster(x = ref_ras,filename = file.path(out.dir, prefix, 'unproj',paste0('unproj_',rasname)), overwrite = T )


      #project to latlong
      ras = projectRaster(ref_ras, crs = as.character(st_crs(city_shape)[2]))
      raster::writeRaster(x = ras,filename = file.path(out.dir,prefix, 'latlong', rasname), overwrite = T )
      
      T
    }
  }
}

#make brdf stuff
cl = makeForkCluster(2)
registerDoParallel(cl)
process_product(brdf, 'brdf', out.dir, over = listofcities, build_albedo_qa)
#process_product(vis[product == 'MOD13A1',], 'MOD13A1', out.dir, over = listofcities, build_vi_qa)
stopImplicitCluster()
stopCluster(cl)







# brdf[,id:=.I]
# dir.create(file.path(out.dir, 'brdf/unproj/'), recursive = T)
# dir.create(file.path(out.dir, 'brdf/latlong/'), recursive = T)
# brdf = brdf[c(2,4,5),]
# print(nrow(brdf))
# for(i in brdf[,id]){
#   print(paste(i, Sys.time()))
#   
#   parallel::mclapply(listofcities, function(x){
#     
#     ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                           layerfolder = '/media/dan/earth_engine/',
#                           metadata = brdf[id == i,],
#                           qa_info = build_albedo_qa(), #same qa as albedo
#                           location_name = x)
#     
#     rasname = paste0(x, '_',brdf[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
#     
#     #native projection
#     raster::writeRaster(x = ref_ras,filename = file.path(out.dir, 'brdf/unproj/',paste0('unproj_',rasname)), overwrite = T )
#     
#     
#     #project to latlong
#     ras = projectRaster(ref_ras, crs = as.character(st_crs(city_shape)[2]))
#     raster::writeRaster(x = ras,filename = file.path(out.dir,'brdf/latlong/', rasname), overwrite = T )
#     return(invisible())
#   },mc.cores = 4)
#   
# }


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
#                           qa_info = build_vi_qa(),
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

# albedo[,id:=.I]
# for(i in albedo[,id]){
#   
#   lapply(listofcities, function(x){
#     
#     ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                           layerfolder = '/media/dan/earth_engine/',
#                           metadata = albedo[id == i,],
#                           qa_info = build_albedobrdf_qa(),
#                           location_name = x)
#     
#     rasname = paste0(x, '_',albedo[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
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

# brdf[,id:=.I]
# dir.create(file.path(out.dir, 'brdf/unproj/'), recursive = T)
# dir.create(file.path(out.dir, 'brdf/latlong/'), recursive = T)
# brdf = brdf[c(2,4,5),]
# print(nrow(brdf))
# for(i in brdf[,id]){
#   print(paste(i, Sys.time()))
#   
#   parallel::mclapply(listofcities, function(x){
#     
#     ref_ras = stich_image(datafolder = '/media/dan/earth_engine/',
#                           layerfolder = '/media/dan/earth_engine/',
#                           metadata = brdf[id == i,],
#                           qa_info = build_albedo_qa(), #same qa as albedo
#                           location_name = x)
#     
#     rasname = paste0(x, '_',brdf[id == i, paste(product,version,variables,year_start,year_end,sep='_')],'.tif')
#     
#     #native projection
#     raster::writeRaster(x = ref_ras,filename = file.path(out.dir, 'brdf/unproj/',paste0('unproj_',rasname)), overwrite = T )
#     
#     
#     #project to latlong
#     ras = projectRaster(ref_ras, crs = as.character(st_crs(city_shape)[2]))
#     raster::writeRaster(x = ras,filename = file.path(out.dir,'brdf/latlong/', rasname), overwrite = T )
#     return(invisible())
#   },mc.cores = 4)
#   
# }
