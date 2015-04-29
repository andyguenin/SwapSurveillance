library(dplyr)
library(reshape)

multmerge = function(){
  ir=list.files(path='./ir', full.names=TRUE)
  ir_l = lapply(ir,read.csv)
  cr=list.files(path='./credit', full.names=TRUE)
  cr_l = lapply(cr,read.csv)
  merge_recurse(datalist)
}
  

elapsed_months <- function(e, b) {
  12*(as.numeric(format.Date(e, "%Y")) - as.numeric(format.Date(b, "%Y"))) + (as.numeric(format.Date(e, "%m")) - as.numeric(format.Date(b, "%m")))
}

get_swap_data <- function(file) {
  f <- paste(file, '.RDS', sep='')
  raw <- readRDS(f)
  rr <- raw %>% 
    select(
      -notional.currency.2, 
      -org.dissemination.id, 
      -action, 
      -cleared, 
      -collateralization,
      -end.user.exception,
      -bespoke.swap,
      -exec.venue,
      -asset.class,
      -asset.subclass,
      -contract.type
    ) %>% 
    mutate(
      exec.timestamp = as.POSIXct(strptime(x = as.character(exec.timestamp), format="%Y-%m-%dT%H:%M:%S.000", tz="GMT")),
      effective.date = as.POSIXct(strptime(effective.date, format = "%m/%d/%Y")),
      end.date = as.POSIXct(strptime(end.date, format = "%m/%d/%Y")),
      notional.currency.amount.1 = as.numeric(gsub(" MM\\+", "000000", notional.currency.amount.1)),
      tenor_r = elapsed_months(end.date, effective.date),
      tenor = elapsed_months(end.date, effective.date)
    ) 
  if(file == 'cr') {
    rr
  } else {
   rr %>%
     filter(!is.na(notional.currency.amount.1)) %>%
     filter(settlement.currency != 'JPY') 
  }  
}
