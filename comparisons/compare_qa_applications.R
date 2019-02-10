library('raster')
library('data.table')

#parse the word
qa_layer = brick('/media/dan/googledrive/gdrive/modis/Kinshasa_MOD13A1_DetailedQA_2015.tif')
bit_interpreter = data.table(word_number = 1:9 ,
                             word_start = c(0,2,6,8,9,10,11,14,15),
                             word_end =   c(1,5,7,8,9,10,13,14,15))

logic = "(word1 ==0 | (word1 == 1 & word2 %in% c(0,1,2,4,8,9,10))) & word7 %in% c(1,2)"
nbits = 16

a = get_qa_values(qa_layer, bit_interpreter = bit_interpreter,logic = logic, nbits = nbits)
b = build_vi_qa()

table(a %in% b)
