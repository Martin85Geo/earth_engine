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

