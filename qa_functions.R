#' A function to translate QA information into a datamask
#' 
#' @param qa_bits numeric. Number of bits of info in the QA
#' @param wordinbits logical. Should the bit word parsing stay in bit format, or translate to numeric within the word
#' @param bit_interpreter data.table. data.table with columns word_number, word_start, word_end
#'
create_qa_mask = function(qa_bits, wordinbits = T, bit_interpreter){
  
  #create a table that translates integer values to bits
  cw = data.table::data.table(intval = 0:(2^qa_bits-1))
  
  #GEE converts the bits into their integer value per word. That conversion is better if least significant digit is on the left
  #modis appears to be the opposite
  if(wordinbits){
    bitorder = qa_bits:1
  }else{
    bitorder = 1:qa_bits
  }
  
  bits = lapply(cw[,intval], function(x) as.integer(intToBits(x))[bitorder]) #starting val is on the lhs.
  bits = do.call(rbind, bits)
  cw = cbind(cw, bits)
  setnames(cw, c('intval',paste0('V',bitorder - 1)))
  
  #create words
  for(qqq in seq(nrow(bit_interpreter))){
    
    
    start = bit_interpreter[qqq,word_start]
    end = bit_interpreter[qqq,word_end]
    i = bit_interpreter[qqq,word_number]
    
    if(wordinbits){
      cw[, paste0('word',i) := apply(.SD, 1, paste, collapse = ""), .SDcols = paste0('V',end:start)]
    } else{
      #convert the word to its integer counterpart
      cw[, paste0('word',i) := rowSums(.SD[, lapply(1:ncol(.SD), function(x) 2^(x-1) * .SD[[x]])]), .SDcols = paste0('V',start:end)] 
    }

  }
  
  #return the grid
  return(cw)
}

build_lst_qa = function(){
  bi = data.table(word_number = 1:4 ,
             word_start = c(0,2,4,6),
             word_end = c(1,3,5,7))
  qa = create_qa_mask(8, F, bi)
  
  #return rows where the data is good at word 1 or word 2
  qa = qa[word1 ==0 | (word1 == 1 & word2 == 0), intval]
  
  return(qa)
  
}

build_vi_qa = function(){
  bi = data.table(word_number = 1:9 ,
                  word_start = c(0,2,6,8,9,10,11,14,15),
                  word_end =   c(1,5,7,8,9,10,13,14,15))
  qa = create_qa_mask(16, F, bi)
  
  #select for data quality
  qa = qa[word1 ==0 | (word1 == 1 & word2 %in% c(0,1,2,4,8,9,10)), ]
  
  #select for land
  qa = qa[word7 %in% c(1,2),intval]
  
  return(qa)
  
}

#reflectance
build_ref_qa = function(band){
  bi = data.table(word_number = 1:10,
                  word_start = c(0,2,6,10,14,18,22,26,30,31),
                  word_end =   c(1,5,9,13,17,21,25,29,30,31))
  qa = create_qa_mask(32, F, bi)
  
  #select for data quality
  # highest quality or internal constant used in place of climate data
  qa = rbindlist(list(
    qa_pair(1,0),
    qa_pair(band+1, c(0,12))
  ))
  
  return(qa)
  
}
qa_pair = function(word_num, good_vals, must = F){
  return(expand.grid(word = paste0('word',word_num), value = good_vals, must = must))
}

get_qa_values = function(qa_layer, bit_interpreter, logic, nbits){
  #find the possible qa combinations
  rasvals = unique(as.vector(qa_layer[]))
  
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
