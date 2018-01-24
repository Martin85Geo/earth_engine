library('data.table')

#Land surface temperature (MOD11A2 & MYD11A2)
lst = setDT(expand.grid(product =c('MOD11A2','MYD11A2'),
                   version = 6,
                   variables = c('LST_Day_1km', 'LST_Night_1km'),
                   lower = 7500,
                   upper = 65535,
                   scale = .02,
                   sensor = 'MODIS',
                   qa_bits = 8))
lst[, qa_layer := paste0('QC_', tstrsplit(variables, "_")[[2]])]

#NDVI and EVI from MOD13A1 and MYD13A1
vis = setDT(expand.grid(product = c('MOD13A1','MYD13A1'),
                        version = 6,
                        variables = c('EVI', 'NDVI'),
                        lower = -2000,
                        upper = 10000,
                        scale = .0001,
                        qa_layer = 'DetailedQA',
                        qa_bits = 16,
                        sensor = 'modis'))

#night time lights
ntl = setDT(expand.grid(product = 'DMSPNTL',
                        version = 4,
                        sensor = 'DMSPNTL',
                        gee_collection_id = 'NOAA/DMSP-OLS/CALIBRATED_LIGHTS_V4'))



