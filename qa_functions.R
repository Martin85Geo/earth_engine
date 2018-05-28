build_lst_qa = function(){
  bi = data.table(word_number = 1:4 ,
             word_start = c(0,2,4,6),
             word_end = c(1,3,5,7))
  
  #return rows where the data is good at word 1 or word 2
  logic = 'word1 ==0 | (word1 == 1 & word2 == 0)'
  
  return(list(bi, logic, 8))
  
}

build_vi_qa = function(){
  bi = data.table(word_number = 1:9 ,
                  word_start = c(0,2,6,8,9,10,11,14,15),
                  word_end =   c(1,5,7,8,9,10,13,14,15))
  
  logic = "(word1 ==0 | (word1 == 1 & word2 %in% c(0,1,2,4,8,9,10)))" # & word7 %in% c(1,2)
  
  return(list(bi, logic, 16))
  
}

#reflectance
build_ref_qa = function(band){
  bi = data.table(word_number = 1:10,
                  word_start = c(0,2,6,10,14,18,22,26,30,31),
                  word_end =   c(1,5,9,13,17,21,25,29,30,31))
  logic = paste0('word1 == 0 | ', paste0('word',band+1), ' %in% c(0, 12)')
  
  return(list(bi, logic, 32))
  
}

build_albedo_qa = function(){
  bi = data.table(word_number = 1,
                  word_start = c(0),
                  word_end =   c(0))
  logic = paste0('word1 == 0')
  
  return(list(bi, logic, 1))
  
}

build_brdf_qa = function(){
  bi = data.table(word_number = 1,
                  word_start = c(0),
                  word_end =   c(2))
  logic = paste0('word1 %in% 0:2')
  
  return(list(bi, logic, 1))
  
}


qa_pair = function(word_num, good_vals){
  return(expand.grid(word = paste0('word',word_num), value = good_vals))
}

get_qa_values = function(qa_layer, bit_interpreter, logic, nbits){
  #find the possible qa combinations
  rasvals = unique(as.vector(qa_layer[]))
  rasvals = rasvals[!is.na(rasvals)]
  
  #convert the observed integers into bits
  bits = lapply(rasvals, function(x) as.integer(intToBits(x)[1:nbits]))
  bits = as.data.table(do.call(rbind, bits))
  bits[, rasval:=rasvals]
  
  setnames(bits, c(paste0('V',0:(nbits-1)), 'rasval'))
  
  for(qqq in seq(nrow(bit_interpreter))){
    
    
    start = bit_interpreter[qqq,word_start]
    end = bit_interpreter[qqq,word_end]
    i = bit_interpreter[qqq,word_number]
    
    #convert the word to its integer counterpart
    bits[, paste0('word',i) := rowSums(.SD[, lapply(1:ncol(.SD), function(x) 2^(x-1) * .SD[[x]])]), .SDcols = paste0('V',start:end)] 
  }
  
  #subset by the supplied logic. Not the best way to do this, but it'll do
  bits = bits[eval(parse(text = logic)),]
  
  return(bits[,rasval])
  
}
