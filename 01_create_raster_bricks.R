#Libs
library('sp')
library('sf')
library('data.table')
library('googledrive')
library('raster')
library('foreach')
library('doParallel')

modis_proj = '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs'
force_proj = T

code.dir = '/home/dan/Documents/code/earth_engine/'
out.dir = '/media/dan/ee_processed/'
#template_grid = raster('/home/dan/Documents/react_data/Cities_React/template_grid.tif') #should be ~1km2

for(ddd in c('qa_functions.R', 'image_processing.R', '00_build_product_metadata.R')) source(paste0(code.dir,ddd))

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/study_areas.shp")
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
      
      if(force_proj){
        crs(ref_ras) = CRS(modis_proj)
      }
      
      raster::writeRaster(x = ref_ras,filename = file.path(out.dir, prefix, 'unproj',paste0('unproj_',rasname)), overwrite = T )


      #project to latlong
      #get the template raster ready
      #buff = st_buffer(city_shape[city_shape$Name==x,], .5)
      # tras = crop(template_grid, as(city_shape[city_shape$Name==x,], 'Spatial'), snap = 'out')
      # 
      # px = dat[i, pixel_size]
      # 
      # #get the pixel sizes proper
      # if(px<1000){
      #   tras = disaggregate(tras, fact = 1000/px)
      # }
      # 
      # if(px>1000){
      #   tras = aggregate(tras, fact = px/1000)
      # }
      
      ras = projectRaster(ref_ras, crs = crs(as(city_shape, 'Spatial')))
      raster::writeRaster(x = ras,filename = file.path(out.dir,prefix, 'latlong', rasname), overwrite = T )
      
      T
    }
  }
}

#make brdf stuff
cl = makeForkCluster(1)
registerDoParallel(cl)
# process_product(lst, 'MOD11A2', out.dir, over = listofcities, build_lst_qa)
process_product(brdf, 'MCD43A4', out.dir, over = listofcities, build_albedo_qa)
#process_product(lst[product=='MYD11A2',], 'MYD11A2', out.dir, over = listofcities, build_lst_qa)

#process_product(vis[product == 'MOD13A1',], 'MOD13A1', out.dir, over = listofcities, build_vi_qa)
stopImplicitCluster()
stopCluster(cl)
