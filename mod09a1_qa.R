library('raster')
library('data.table')

bla = brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD13A1_DetailedQA_2013.tif')
  #brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD09A1_QA_2013.tif')
nbits = 16
rasvals = unique(as.vector(bla[]))

#find their bits
bits = lapply(rasvals, function(x) as.integer(intToBits(x)[1:nbits]))
bits = as.data.table(do.call(rbind, bits))
bits[, rasval:=rasvals]

setnames(bits, c(paste0('V',0:(nbits-1)), 'rasval'))

cw = copy(bits)
#parse the word
bit_interpreter = data.table(word_number = 1:9 ,
                             word_start = c(0,2,6,8,9,10,11,14,15),
                             word_end =   c(1,5,7,8,9,10,13,14,15))

for(qqq in seq(nrow(bit_interpreter))){
  
  
  start = bit_interpreter[qqq,word_start]
  end = bit_interpreter[qqq,word_end]
  i = bit_interpreter[qqq,word_number]
  
  #convert the word to its integer counterpart
  cw[, paste0('word',i) := rowSums(.SD[, lapply(1:ncol(.SD), function(x) 2^(x-1) * .SD[[x]])]), .SDcols = paste0('V',start:end)] 
}

logic = "(word1 ==0 | (word1 == 1 & word2 %in% c(0,1,2,4,8,9,10))) & word7 %in% c(1,2)"

blarg = cw[eval(parse(text = logic)),]

qa = rbindlist(list(
  qa_pair(1,0),
  w
))
qa = qa[word1 ==0 | (word1 == 1 & word2 %in% c(0,1,2,4,8,9,10)), ]

#select for land
qa = qa[word7 %in% c(1,2),intval]


#merge in the good word and value pairs

#return list of good value
