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

