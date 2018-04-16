library('data.table')

#Land surface temperature (MOD11A2 & MYD11A2)
lst = setDT(expand.grid(product =c('MOD11A2','MYD11A2'),
                   version = '006',
                   variables = c('LST_Day_1km', 'LST_Night_1km'),
                   lower = 7500,
                   upper = 65535,
                   qa_na = 0,
                   scale = .02,
                   sensor = 'MODIS',
                   qa_bits = 8,
                   year_start = 2001,
                   year_end = 2016, stringsAsFactors = F))
lst[, qa_layer := paste0('QC_', tstrsplit(variables, "_")[[2]])]

#NDVI and EVI from MOD13A1 and MYD13A1
vis = setDT(expand.grid(product = c('MOD13A1','MYD13A1'),
                        version = '006',
                        variables = c('EVI', 'NDVI'),
                        lower = -2000,
                        upper = 10000,
                        qa_na = 65535,
                        scale = .0001,
                        qa_layer = 'DetailedQA',
                        qa_bits = 16,
                        sensor = 'MODIS',
                        year_start = 2001,
                        year_end = 2016, stringsAsFactors = F))

#night time lights
ntl = setDT(expand.grid(product = 'DMSPNTL',
                        version = 4,
                        sensor = 'DMSPNTL',
                        gee_collection_id = 'NOAA/DMSP-OLS/CALIBRATED_LIGHTS_V4', stringsAsFactors = F))


#Reflectance
reflect = setDT(expand.grid(product = c('MOD09A1'),
                        version = '006',
                        variables = paste0('sur_refl_b0',1:7),
                        lower = -100,
                        upper = 16000,
                        qa_na = 4294967295,
                        scale = .0001,
                        qa_layer = 'QA',
                        qa_bits = 32,
                        sensor = 'MODIS',
                        year_start = 2001,
                        year_end = 2016, stringsAsFactors = F))

#Albedo reflect
albedo = setDT(expand.grid(product = c('MCD43A3'),
                           version = '006',
                           variables = c(paste0('Albedo_BSA_Band',c(1:7,'_vis','_nir','_shortwave')),
                                         paste0('Albedo_WSA_Band',c(1:7,'_vis','_nir','_shortwave'))),
                           lower = 0,
                           upper = 32766,
                           qa_na = 2,
                           scale = .001,
                           qa_layer = 'QA',
                           qa_bits = 1,
                           sensor = 'MODIS',
                           year_start = 2001,
                           year_end = 2016, stringsAsFactors = F))
#overwrite the QA layer names
albedo[,qa_layer:= paste0('BRDF_Albedo_Band_Mandatory_Quality_',
                          c(paste0('Band',1:7),'vis','nir','shortwave'))]

#brdf reflect
brdf = setDT(expand.grid(product = c('MCD43A4'),
                           version = '006',
                           variables = c(paste0('Nadir_Reflectance_Band',1:7)),
                           lower = 0,
                           upper = 32766,
                           qa_na = 2,
                           scale = .001,
                           qa_layer = 'QA',
                           qa_bits = 1,
                           sensor = 'MODIS',
                           year_start = 2001,
                           year_end = 2016, stringsAsFactors = F))
#overwrite the QA layer names
brdf[,qa_layer:= paste0('BRDF_Albedo_Band_Mandatory_Quality_',
                          c(paste0('Band',1:7)))]
