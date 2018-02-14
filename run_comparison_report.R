library('knitr')
library('sf')
library(data.table)

city_shape = st_read("/home/dan/Documents/react_data/Cities_React/Boundaries.shp")
listofcities = as.character(city_shape$Name)

for(cit in listofcities){
  print(cit)
  diagfolder = paste0('/media/dan/ee_res/compare_reports/')
  rmarkdown::render(input = '/home/dan/Documents/code/earth_engine/ee_lpdaac_comparison_report.Rmd', output_format = "html_document",
                    output_file = paste0('comparison_report_',cit),
                    params = list(city = cit), intermediates_dir = diagfolder, knit_root_dir = diagfolder, output_dir = diagfolder, envir = new.env())
}