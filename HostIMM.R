# algorithm for analysing host imm messages
# objective: to check whether imm messages are only generated when product attributes are modified
#
#
# author: isaac adjei-attah
###################################################################################################

setwd("e:/projects/")

dir.create("host_import")
setwd("host_import")


# load required libraries
#########################################################

library(dplyr); library(sqldf); library(lubridate)

# create a test file to motivate algorithm
#########################################################

df <- data.frame(dates = c("2019-03-01", "2019-03-01", "2019-03-01", "2019-03-02", "2019-03-02", "2019-03-03", "2019-03-03", "2019-03-03"),
                 prodid = c("1001", "1002", "1003", "1001", "1001", "1002", "1001", "1003"), 
                 size = c(152, 120, 111, 121, 152, 120, 152, 112), 
                 colour = c("blue", "green", "black", "blue", "blue", "green", "blue", "black"), 
                 stringsAsFactors = F)

df$dates <- ymd(df$dates)



# algorithm

udates <- unique(df$dates)[order(unique(df$dates))]
results <- vector("numeric")


# algorithm
###################################################################

for(i in (length(udates) - 1)){
  
  records1 <- df %>%
    filter(dates == udates[i]) %>%
    select(-dates)
  
  records2 <- df %>%
    filter(dates == udates[i+1]) %>%
    select(-dates)
  
  records <- rbind(records1, records2)
  
  
  # get distinct list of records
  urecords <- unique(records)
  
  
  
  # initial frequency
  #################################################################
  
  frame1 <- records %>%
    group_by(prodid) %>%
    summarise(N=n())
  
  
  # final frequency
  ##################################################################
  
  frame2 <- urecords %>%
    group_by(prodid) %>%
    summarise(updates=n())
  
  # join tables
  #################################################################
  
  outframe <- merge(frame1, frame2, by="prodid")
  
  # tidy up analysis
  #################################################################
  
  output <- outframe %>%
    filter(N > 1) %>%
    mutate(validMessages = ifelse(updates > 1, 1, 0))
  

  
  # message validity assessment
  ##################################################################
  output <- prop.table(table(output$validMessages))[1]
  
  results[i] <- output
  
}

urecords <- sqldf("select distinct * from df")


# initial frequency
#################################################################

outframe1 <- df %>%
  group_by(prodid) %>%
  summarise(N=n())
  

# final frequency
##################################################################

outframe2 <- urecords %>%
  group_by(prodid) %>%
  summarise(updates=n())

# join tables
#################################################################

outframe <- merge(outframe1, outframe2, by="prodid")

# tidy up analysis
#################################################################

results <- outframe %>%
  filter(N > 1) %>%
  mutate(validMessages = ifelse(updates > 1, 1, 0))

results

# message validity assessment
##################################################################
prop.table(table(results$validMessages))
