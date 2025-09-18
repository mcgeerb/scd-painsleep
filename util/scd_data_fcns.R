
# functions
find_rows_for_patients <- function(data_obj,ID_num){
  tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
}

gather_pain_or_sleep_trajectories <- function(data_obj,ID_num,pain_or_sleep = 'P',interp_nas=FALSE){
  tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
  if (pain_or_sleep == 'P'){
    tempTraj <- data_obj[tempRows,"PainYNSev"]
  }else{
    tempTraj <- data_obj[tempRows,"SleepQ"]
  }
  if (interp_nas){ # option to perform spline interpolation 
    tempTraj <- na.spline(tempTraj) # replace NAs to get a continuous curve
    tempTraj[tempTraj<0] <- 0 # tempfix for A-10 spline issue at endpoint
  }
  return(tempTraj)
}

cleanup_drug_info <- function(data_obj){
  # columns associated with drug information
  drug_columns = c("PainMed","PainMedYN","Analgesic","Narcotic","OtherPM","OtherMed","OtherMDYN","Dhydrox","FolicAcid","NPSM")
  # clean up spellings
  advil_rows = grep('vil',data_obj[,"PainMed"])
  data_obj[advil_rows,"PainMed"] = 'Advil'
  aleve_rows = grep('leve',data_obj[,"PainMed"])
  data_obj[aleve_rows,"PainMed"] = 'Aleve'
  excedrin_rows = grep('excer',data_obj[,"PainMed"])
  data_obj[excedrin_rows,"PainMed"] = 'Excedrin'
  ondansetron_rows = grep('tron',data_obj[,"PainMed"])
  data_obj[ondansetron_rows,"PainMed"] = 'Ondansetron'
  cetirizine_rows = grep('zin',data_obj[,"PainMed"])
  data_obj[cetirizine_rows,"PainMed"] = 'Cetirizine'
  hyfa_rows = grep(',',data_obj[,"PainMed"])
  data_obj[hyfa_rows,"PainMed"] = 'Hydroxyurea, Folic acid'
  #note that [52] "hydrourea, folic, caltrate, complete chewable multivitamin."
  hydroxyurea_rows = grep('(ea|ia)$',data_obj[,"PainMed"])
  data_obj[hydroxyurea_rows,"PainMed"] = 'Hydroxyurea'
  folicacid_rows = grep('^f',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[folicacid_rows,"PainMed"] = 'Folic Acid'
  oxy_rows = grep('^Oxy',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[oxy_rows,"PainMed"] = 'OxyContin'
  tramadol_rows = grep('dol',data_obj[,"PainMed"])
  data_obj[tramadol_rows,"PainMed"] = 'Tramadol'
  pamprin_rows = grep('amp',data_obj[,"PainMed"])
  data_obj[pamprin_rows,"PainMed"] = 'Pamprin'
  ranitidine_rows = grep('^ran',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[ranitidine_rows,"PainMed"] = 'Ranitidine'
  # capitalize - not sure this is necessary
  require("stringr")
  data_obj[,"PainMed"] <- str_to_title(data_obj[,"PainMed"])
  # handle the Nones/NAs - if some drug related info is not NA, then NA in PainMed = None
  ind <- rowSums(is.na(data_obj[,drug_columns])) == ncol(data_obj[,drug_columns])
  NAnone_rows <- grep('NA',data_obj[-ind,"PainMed"])
  data_obj[NAnone_rows,"PainMed"] = 'None'
  # Show the cleaning procedure, print out the unique ones, then do the above block, show output
  #test2 <- data_obj[,"PainMed"]
  #Browse[2]> utest2
  #GET THOSE STEPS FROM REBECCA
  # investigate the drug entries for a patient after cleaning
  # Browse[2]> ID_num = "A-7"
  # Browse[2]>   tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
  # Browse[2]> data_obj[tempRows,drug_columns]
  #Check what percent are all NAs after the entry
  data_obj
}  

export_data_for_simulation <- function(data_obj,ID_num,pain_or_sleep = 'P',replace_nas=FALSE){
  # pain
  # sleep
  # drug
  # time?
  # morning evening / 
  # export to csv
  tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
  # columns associated with drug information
  drug_columns = c("PainMed","PainMedYN","Analgesic","Narcotic","OtherPM","OtherMed","OtherMDYN","Dhydrox","FolicAcid","NPSM")
  # clean up spellings
  advil_rows = grep('vil',data_obj[,"PainMed"])
  data_obj[advil_rows,"PainMed"] = 'Advil'
  aleve_rows = grep('leve',data_obj[,"PainMed"])
  data_obj[aleve_rows,"PainMed"] = 'Aleve'
  excedrin_rows = grep('excer',data_obj[,"PainMed"])
  data_obj[excedrin_rows,"PainMed"] = 'Excedrin'
  ondansetron_rows = grep('tron',data_obj[,"PainMed"])
  data_obj[ondansetron_rows,"PainMed"] = 'Ondansetron'
  cetirizine_rows = grep('zin',data_obj[,"PainMed"])
  data_obj[cetirizine_rows,"PainMed"] = 'Cetirizine'
  hyfa_rows = grep(',',data_obj[,"PainMed"])
  data_obj[hyfa_rows,"PainMed"] = 'Hydroxyurea, Folic acid'
  #note that [52] "hydrourea, folic, caltrate, complete chewable multivitamin."
  hydroxyurea_rows = grep('(ea|ia)$',data_obj[,"PainMed"])
  data_obj[hydroxyurea_rows,"PainMed"] = 'Hydroxyurea'
  folicacid_rows = grep('^f',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[folicacid_rows,"PainMed"] = 'Folic Acid'
  oxy_rows = grep('^Oxy',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[oxy_rows,"PainMed"] = 'OxyContin'
  tramadol_rows = grep('dol',data_obj[,"PainMed"])
  data_obj[tramadol_rows,"PainMed"] = 'Tramadol'
  pamprin_rows = grep('amp',data_obj[,"PainMed"])
  data_obj[pamprin_rows,"PainMed"] = 'Pamprin'
  ranitidine_rows = grep('^ran',data_obj[,"PainMed"],ignore.case = TRUE)
  data_obj[ranitidine_rows,"PainMed"] = 'Ranitidine'
  # capitalize - not sure this is necessary
  require("stringr")
  data_obj[,"PainMed"] <- str_to_title(data_obj[,"PainMed"])
  # handle the Nones/NAs - if some drug related info is not NA, then NA in PainMed = None
  ind <- rowSums(is.na(data_obj[,drug_columns])) == ncol(data_obj[,drug_columns])
  NAnone_rows <- grep('NA',data_obj[-ind,"PainMed"])
  data_obj[NAnone_rows,"PainMed"] = 'None'
  # Show the cleaning procedure, print out the unique ones, then do the above block, show output
  #test2 <- data_obj[,"PainMed"]
  #Browse[2]> utest2
 #GET THOSE STEPS FROM REBECCA
  # investigate the drug entries for a patient after cleaning
  # Browse[2]> ID_num = "A-7"
  # Browse[2]>   tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
  # Browse[2]> data_obj[tempRows,drug_columns]
#Check what percent are all NAs after the entry

  #Add in LA, SA, NO column
  
  #Split LA SA from Narcotic
  # add SA/LA column
  

  
  
  # data_obj[tempRows,c("MorEve","PainMed")]
  
  data_obj[tempRows,c("PainYNSev","SleepQ","MorEve","PainMed","Analgesic",)]
  if (pain_or_sleep == 'P'){
    tempTraj <- data_obj[tempRows,"PainYNSev"]
  }else{
    tempTraj <- data_obj[tempRows,"SleepQ"]
  }
  if (replace_nas){ # change to an interpolation / interp_nas
    tempTraj[is.na(tempTraj)] <- 0 # probably remove this 4/15/21
  }
  return(tempTraj)
}

plot_pain_and_sleep_trajectories <- function(data_obj,ID_num){
  # plot a discontinuous curve with breaks at the NAs - https://stackoverflow.com/questions/14821064/line-break-when-no-data-in-ggplot2
  require(zoo)
  require(ggplot2)
  require(wesanderson)
  col_wes <- wes_palette(n=4,name="GrandBudapest2")
  colors <- c("Pain Severity" = col_wes[1], "Sleep Quality" = col_wes[4])
  # find relevant rows for the ID
  IDEntries <- data_obj[,"ID#"]==ID_num
  painRows <- seq(1:dim(data_obj)[1])[IDEntries]
  mornEntries <- IDEntries & data_obj[,"MorEve"]==0 # might have to be more delicate here in case there are NAs 4/29/15
  sleepRows <- seq(1:dim(data_obj)[1])[mornEntries]
  count_pain_entries <- seq(length(painRows)) 
  count_sleep_entries <- seq(length(sleepRows)) 
  # make tick marks
  day_ticks <- rep("",length(count_pain_entries))
  day_ticks[c(TRUE,FALSE)] <- paste0("Day ",seq(length(count_sleep_entries))) # replace ever other entry with Day #
  # gather sleep data / make constant for each day
  tempSleep <- data_obj[sleepRows,"SleepQ"]
  tempSleep <- rep(tempSleep,each=2) # need this the same length for plotting 
  # NOTE: eventually will need a check/condition that these will always be the same length for each patient
  # create grouping and pch variables
  pain_grps <- cumsum(is.na(data_obj[painRows,"PainYNSev"])) 
  sleep_grps <- rep(count_sleep_entries,each=2)
  tempMorEve <- data_obj[painRows,"MorEve"]
  tempMorEve[tempMorEve == 0] <- "Morning"
  tempMorEve[tempMorEve == 1] <- "Evening"
  Morning_Or_Evening <- as.factor(tempMorEve)
  rm(count_sleep_entries,tempMorEve)
  # plotting
  plot_obj <- ggplot(data_obj[painRows,], aes(x=Entry, y=PainYNSev, shape = Morning_Or_Evening, group = pain_grps)) + # basic graphical object
    geom_line(aes(color="Pain severity"),size=1.2,na.rm = TRUE) + # first layer / plot pain trajectory
    geom_point(color=col_wes[1], size=2.3, na.rm = TRUE)+ # second layer / plot morning/evening points
    geom_line(aes(y=tempSleep, colour="Sleep quality", group = sleep_grps), size=1.2, na.rm = TRUE) + # third layer / plot sleep trajectory 
    geom_point(aes(y=tempSleep), color=col_wes[4], size=2.3, na.rm=TRUE) + # fourth layer - morning/evening points
    scale_color_manual(values=c(col_wes[1], col_wes[4])) + # adjust lines colors
    scale_x_continuous(breaks=count_pain_entries,labels = day_ticks) + # add xticks at each entry
    labs(title = paste0("Patient ",ID_num), x = "Day", y = "Magnitude",color = "Measurement", shape = 'Time of Day') + # labels all legends and axes
    theme(axis.text.x = element_text(angle = 90)) # rotate for clarity
  return(plot_obj)
}

plot_pain_and_sleep_trajectories_piecewise <- function(data_obj,ID_num){
  # plot a discontinuous curve with breaks at the NAs - https://stackoverflow.com/questions/14821064/line-break-when-no-data-in-ggplot2
  # outdated? I think this the later one is the same, but adds geom_point()
  require(zoo)
  require(ggplot2)
  require(wesanderson)
  col_wes <- wes_palette(n=4,name="GrandBudapest2")
  # find rows for the ID
  IDEntries <- data_obj[,"ID#"]==ID_num
  mornEntries <- IDEntries & data_obj[,"MorEve"]==0
  painRows <- seq(1:dim(data_obj)[1])[IDEntries]
  sleepRows <- seq(1:dim(data_obj)[1])[mornEntries]
  count_pain_entries <- seq(length(painRows)) 
  count_sleep_entries <- seq(length(sleepRows)) # could probably remove this simplify
  # gather data
  tempPain <- data_obj[painRows,"PainYNSev"]
  entry_grps <- cumsum(is.na(tempPain))
  #tempPain <- na.spline(tempPain) # replace NAs to get a continuous curve
  #tempPain[tempPain<0] <- 0 # tempfix for A-10 spline issue at endpoint
  tempSleep <- data_obj[sleepRows,"SleepQ"]
  tempSleep <- na.spline(tempSleep) # replace NAs to get a continuous curve
  tempSleep[tempSleep<0] <- 0 # tempfix for A-10 spline issue at endpoint
  tempSleep <- rep(tempSleep,each=2) # need this the same length for plotting 
  # NOTE: eventually will need a check/condition that these will always be the same length for each patient
  # plotting
  plot_obj <-ggplot(data_obj[painRows,], aes(count_pain_entries,shape = factor("Pain Severity","Sleep Quality"))) +     # basic graphical object
    geom_line(aes(y=tempPain), colour=col_wes[1], size=1.2,group = entry_grps) +  # first layer
    geom_line(aes(y=tempSleep), colour=col_wes[4], size=1.2) +  # second layer
    labs(title = paste0("Patient ",ID_num), x = "Entries", y = "Pain Severity || Sleep Quality") 
  return(plot_obj)
}

plot_pain_and_sleep_trajectories_spline <- function(data_obj,ID_num){
  require(zoo)
  require(ggplot2)
  require(wesanderson)
  col_wes <- wes_palette(n=4,name="GrandBudapest2")
  # find rows for the ID
  IDEntries <- data_obj[,"ID#"]==ID_num
  mornEntries <- IDEntries & data_obj[,"MorEve"]==0
  painRows <- seq(1:dim(data_obj)[1])[IDEntries]
  sleepRows <- seq(1:dim(data_obj)[1])[mornEntries]
  count_pain_entries <- seq(length(painRows)) 
  count_sleep_entries <- seq(length(sleepRows)) # could probably remove this simplify
  # gather data
  tempPain <- data_obj[painRows,"PainYNSev"]
  tempPain <- na.spline(tempPain) # replace NAs to get a continuous curve
  tempPain[tempPain<0] <- 0 # tempfix for A-10 spline issue at endpoint
  tempSleep <- data_obj[sleepRows,"SleepQ"]
  tempSleep <- na.spline(tempSleep) # replace NAs to get a continuous curve
  tempSleep[tempSleep<0] <- 0 # tempfix for A-10 spline issue at endpoint
  tempSleep <- rep(tempSleep,each=2) # need this the same length for plotting 
  # NOTE: eventually will need a check/condition that these will always be the same length for each patient
  # plotting
  plot_obj <-ggplot(data_obj[painRows,], aes(count_pain_entries,shape = factor("Pain Severity","Sleep Quality"))) +     # basic graphical object
    geom_line(aes(y=tempPain), colour=col_wes[1], size=1.2) +  # first layer
    geom_line(aes(y=tempSleep), colour=col_wes[4], size=1.2) +  # second layer
    labs(title = paste0("Patient ",ID_num), x = "Entries", y = "Pain Severity || Sleep Quality") 
  return(plot_obj)
}


#original function from before 4/13/21
plot_pain_and_sleep_trajectories_with_zeros_for_NAs <- function(data_obj,ID_num){
  require(ggplot2)
  require(wesanderson)
  col_wes <- wes_palette(n=4,name="GrandBudapest2")
  # find rows for the ID
  tempRows <- seq(1:dim(data_obj)[1])[data_obj[,"ID#"]==ID_num]
  count_num_entries <- seq(length(tempRows))
  # gather data
  tempPain <- data_obj[tempRows,"PainYNSev"]
  tempPain[is.na(tempPain)] <- 0 # replace NAs to get a continuous curve
  tempSleep <- data_obj[tempRows,"SleepQ"]
  tempSleep[is.na(tempSleep)] <- 0 # replace NAs to get a continuous curve
  # plotting
  plot_obj <-ggplot(data_obj[tempRows,], aes(count_num_entries,shape = factor("Pain Severity","Sleep Quality"))) +     # basic graphical object
    geom_line(aes(y=tempPain), colour=col_wes[1], size=1.2) +  # first layer
    geom_line(aes(y=tempSleep), colour=col_wes[4], size=1.2) +  # second layer
    labs(title = paste0("Patient ",ID_num), x = "Entries", y = "Pain Severity || Sleep Quality")
  return(plot_obj)
}

generate_pain_response_curves <- function(temp_data,possible_ID_lists,num_bins,no_drug_influence = FALSE){
  
  # note on the output
  # if there is no influence of drugs considered (i.e., no_drug_influence = TRUE) the you want to look in 
  # the output pain_response_to_sleep[partition_idx+1,cur_list_idx,1] since pain_response_to_sleep[partition_idx+1,cur_list_idx,2] 
  # will be all -10s (see lines 330-336 )
  
  # compute the width of the bins
  width_of_bins <- 100/num_bins
  
  # generate arrays to store outputs
  population_diary_length <- array(NA,dim=c(1,length(possible_ID_lists),2))
  
  stats_sleep_quals <- matrix(NA,nrow=7,ncol=length(possible_ID_lists))
  row.names(stats_sleep_quals) <- c("Average sleep quality","Nights above sleep average","Nights below sleep average","Total # of entries","Average # of entries","Average # of bad sleep nights","Standard deviation")
  colnames(stats_sleep_quals) <- possible_ID_lists
  
  pain_response_to_sleep <- array(NA, dim=c(num_bins,length(possible_ID_lists),2)) 
  row.names(pain_response_to_sleep) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(pain_response_to_sleep) <- possible_ID_lists
  
  stats_on_drugfree_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  stats_on_drug_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  row.names(stats_on_drugfree_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_drugfree_pain) <- possible_ID_lists
  row.names(stats_on_drug_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_drug_pain) <- possible_ID_lists
  
  # main code
  for (cur_list_idx in seq(1,length(possible_ID_lists))){ # for each column in table
    all_cur_sleep_quals <- c()  # these only needs to be computed for each subpopulation
    all_cur_diary_lengths <- c() # these only needs to be computed for each subpopulation
    for (partition_idx in seq(0,num_bins-1)){ # for each row in table
      all_cur_pain_DrugFree <- c()
      all_cur_pain_Drug <- c()
      cur_list <- get(possible_ID_lists[cur_list_idx])
      for (cur_ID in cur_list){ # for each patient in subpopulation
        # further processes/prepares the data
        cur_rows <- temp_data[,"ID#"] %in% cur_ID
        cur_diary_length <- sum(cur_rows) 
        cur_cur_data <- temp_data[cur_rows,]
        num_entries <- dim(cur_cur_data)[1]
        # find first entry where pain or sleep is reported
        non_na_entries <- !apply(is.na(cur_cur_data[,c("PainYNSev","SleepQ")]),FUN = all,MARGIN = 1) # checks if both Pain and Sleep are NA for each entry
        first_non_na_entry <- as.integer(which(non_na_entries)[1])
        actual_entries <- seq(first_non_na_entry,num_entries)
        cur_data <- cur_cur_data[actual_entries,]
        if (partition_idx == 0){ # first iteration of the "for each row" loop
          key <- 100-width_of_bins <= cur_data$SleepQ & cur_data$SleepQ <= 100 # same as line 324 except right is <=
          # these only needs to be computed for each subpopulation (on the first iteration)
          non_na_sleep_temp<- cur_data[cur_data$MorEve == 0,"SleepQ"]
          non_na_sleep_data <- non_na_sleep_temp[!is.na(non_na_sleep_temp)]
          all_cur_sleep_quals <- c(all_cur_sleep_quals,non_na_sleep_data)
          all_cur_diary_lengths <- c(all_cur_diary_lengths,length(non_na_sleep_data)) # sum the non NA morning entries
        }else{
          key <- 100-width_of_bins*(partition_idx+1) <= cur_data$SleepQ & cur_data$SleepQ < 100-width_of_bins*(partition_idx) # same as line 317
        }
        pain_to_avg_idxs <- as.vector(na.omit(seq(1,length(key))[key]))+1 # index for pain the next day
        if (no_drug_influence == TRUE){
          # commented steps aren't needed when there's no drug influence
          #drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          #cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          #drugfree_day_pain_subidx <- cur_temp == 0
          #drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,-10)
          all_cur_pain_Drug <- c(all_cur_pain_Drug,cur_data[pain_to_avg_idxs,"PainYNSev"])
        }else{ # split into drug and drug free
          drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          drugfree_day_pain_subidx <- cur_temp == 0
          drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,cur_data[pain_to_avg_idxs[drugfree_day_pain_subidx],"PainYNSev"])
          all_cur_pain_Drug <- c(all_cur_pain_Drug,cur_data[pain_to_avg_idxs[drug_day_pain_subidx],"PainYNSev"])
        }
      } # end loop over IDs
      pain_response_to_sleep[partition_idx+1,cur_list_idx,2] <- mean(all_cur_pain_DrugFree,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,1] <- mean(all_cur_pain_Drug,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      stats_on_drugfree_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_DrugFree),sd(all_cur_pain_DrugFree,na.rm = TRUE),min(all_cur_pain_DrugFree,na.rm = TRUE),max(all_cur_pain_DrugFree,na.rm = TRUE))
      stats_on_drug_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_Drug),sd(all_cur_pain_Drug,na.rm = TRUE),min(all_cur_pain_Drug,na.rm = TRUE),max(all_cur_pain_Drug,na.rm = TRUE))
      # what's the range and the standard deviation on the pain so we can get error bars
      cur_avg_sleep_qual <- mean(all_cur_sleep_quals,na.rm = TRUE)
      stats_sleep_quals[1,cur_list_idx] <- cur_avg_sleep_qual # average sleep quality
      stats_sleep_quals[2,cur_list_idx] <- sum(cur_avg_sleep_qual < all_cur_sleep_quals,na.rm=TRUE) # num of entries above average
      stats_sleep_quals[3,cur_list_idx] <- sum(cur_avg_sleep_qual > all_cur_sleep_quals,na.rm=TRUE) # num of entries below average
      stats_sleep_quals[4,cur_list_idx] <- sum(all_cur_diary_lengths) # total # of entries
      stats_sleep_quals[5,cur_list_idx] <- sum(all_cur_diary_lengths)/length(cur_list) # average # of entries
      stats_sleep_quals[6,cur_list_idx] <- ceiling(stats_sleep_quals[3,cur_list_idx]/length(cur_list)) # average # of nights of bad sleep
      #stats_sleep_quals[6,cur_list_idx] <- sum(rle(cur_avg_sleep_qual > all_cur_sleep_quals)$length>1&rle(cur_avg_sleep_qual > all_cur_sleep_quals)$values)/length(cur_list) # average # of consecutive nights below average
      stats_sleep_quals[7,cur_list_idx] <- sd(all_cur_sleep_quals,na.rm = TRUE) # standard deviation of sleep quality
    } # end loop over partitions
  }
  
  # statistics for HF_C_Drug (interesting in fig 111 cause of the dip) in:
  # stats_on_drug_pain[,3,]

  output<-list(pain_response_to_sleep,stats_sleep_quals,stats_on_drug_pain,stats_on_drugfree_pain)
  return(output)
}

generate_pain_response_curves_r01 <- function(temp_data,possible_ID_lists,num_bins,no_drug_influence = FALSE){
  
  # note on the output
  # if there is no influence of drugs considered (i.e., no_drug_influence = TRUE) the you want to look in 
  # the output pain_response_to_sleep[partition_idx+1,cur_list_idx,1] since pain_response_to_sleep[partition_idx+1,cur_list_idx,2] 
  # will be all -10s (see lines 330-336 )
  
  # compute the width of the bins
  width_of_bins <- 100/num_bins
  
  # generate arrays to store outputs
  population_diary_length <- array(NA,dim=c(1,length(possible_ID_lists),2))
  
  stats_sleep_quals <- matrix(NA,nrow=7,ncol=length(possible_ID_lists))
  row.names(stats_sleep_quals) <- c("Average sleep quality","Nights above sleep average","Nights below sleep average","Total # of entries","Average # of entries","Average # of bad sleep nights","Standard deviation")
  colnames(stats_sleep_quals) <- possible_ID_lists
  
  pain_response_to_sleep <- array(NA, dim=c(num_bins,length(possible_ID_lists),3)) 
  row.names(pain_response_to_sleep) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(pain_response_to_sleep) <- possible_ID_lists
  
  stats_on_drugfree_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  #dimnames(stats_on_drugfree_pain)[3] <- c("Sample Size",Std. Dev","Min pain","Max Paid")
  stats_on_opioid_pain <- stats_on_drugfree_pain
  stats_on_nonopioid_pain <- stats_on_drugfree_pain

  row.names(stats_on_drugfree_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_drugfree_pain) <- possible_ID_lists
  row.names(stats_on_opioid_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_opioid_pain) <- possible_ID_lists
  row.names(stats_on_nonopioid_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_nonopioid_pain) <- possible_ID_lists
  
  # main code
  for (cur_list_idx in seq(1,length(possible_ID_lists))){ # for each column in table
    all_cur_sleep_quals <- c()  # these only needs to be computed for each subpopulation
    all_cur_diary_lengths <- c() # these only needs to be computed for each subpopulation
    for (partition_idx in seq(0,num_bins-1)){ # for each row in table
      all_cur_pain_DrugFree <- c()
      all_cur_pain_NonOpioid <- c()
      all_cur_pain_Opioid <- c()
      cur_list <- get(possible_ID_lists[cur_list_idx])
      for (cur_ID in cur_list){ # for each patient in subpopulation
        # further processes/prepares the data
        cur_rows <- temp_data[,"ID#"] %in% cur_ID
        cur_diary_length <- sum(cur_rows) 
        cur_cur_data <- temp_data[cur_rows,]
        num_entries <- dim(cur_cur_data)[1]
        # find first entry where pain or sleep is reported
        non_na_entries <- !apply(is.na(cur_cur_data[,c("PainYNSev","SleepQ")]),FUN = all,MARGIN = 1) # checks if both Pain and Sleep are NA for each entry
        first_non_na_entry <- as.integer(which(non_na_entries)[1])
        actual_entries <- seq(first_non_na_entry,num_entries)
        cur_data <- cur_cur_data[actual_entries,]
        if (partition_idx == 0){ # first iteration of the "for each row" loop
          key <- 100-width_of_bins <= cur_data$SleepQ & cur_data$SleepQ <= 100 # same as line 324 except right is <=
          # these only needs to be computed for each subpopulation (on the first iteration)
          non_na_sleep_temp<- cur_data[cur_data$MorEve == 0,"SleepQ"]
          non_na_sleep_data <- non_na_sleep_temp[!is.na(non_na_sleep_temp)]
          all_cur_sleep_quals <- c(all_cur_sleep_quals,non_na_sleep_data)
          all_cur_diary_lengths <- c(all_cur_diary_lengths,length(non_na_sleep_data)) # sum the non NA morning entries
        }else{
          key <- 100-width_of_bins*(partition_idx+1) <= cur_data$SleepQ & cur_data$SleepQ < 100-width_of_bins*(partition_idx) # same as line 317
        }
        pain_to_avg_idxs <- as.vector(na.omit(seq(1,length(key))[key]))+1 # index for pain the next day
        if (no_drug_influence == TRUE){
          # commented steps aren't needed when there's no drug influence
          #drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          #cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          #drugfree_day_pain_subidx <- cur_temp == 0
          #drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,-10)
          all_cur_pain_NonOpioid <- all_cur_pain_DrugFree
          all_cur_pain_Opioid <- c(all_cur_pain_Opioid,cur_data[pain_to_avg_idxs,"PainYNSev"])
        }else{ # split into drug and drug free
          drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          drugfree_day_pain_subidx <- cur_temp == 0
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,cur_data[pain_to_avg_idxs[drugfree_day_pain_subidx],"PainYNSev"])
          drug_day_pain_subidx <- cur_temp == 1
          were_drugs_opioids_subidx <- cur_data[drugs_to_check_idxs,c("PainMed")] %in% c("Tramadol","Morphine","Oxycontin","Lortab","Tylenol With Codeine")
          all_cur_pain_Opioid <- c(all_cur_pain_Opioid,cur_data[pain_to_avg_idxs[drug_day_pain_subidx & were_drugs_opioids_subidx],"PainYNSev"])
          all_cur_pain_NonOpioid <- c(all_cur_pain_NonOpioid,cur_data[pain_to_avg_idxs[drug_day_pain_subidx & !were_drugs_opioids_subidx],"PainYNSev"])
        }
      } # end loop over IDs
      pain_response_to_sleep[partition_idx+1,cur_list_idx,3] <- mean(all_cur_pain_NonOpioid,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,2] <- mean(all_cur_pain_DrugFree,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,1] <- mean(all_cur_pain_Opioid,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      stats_on_drugfree_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_DrugFree),sd(all_cur_pain_DrugFree,na.rm = TRUE),min(all_cur_pain_DrugFree,na.rm = TRUE),max(all_cur_pain_DrugFree,na.rm = TRUE))
      stats_on_opioid_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_Opioid),sd(all_cur_pain_Opioid,na.rm = TRUE),min(all_cur_pain_Opioid,na.rm = TRUE),max(all_cur_pain_Opioid,na.rm = TRUE))
      stats_on_nonopioid_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_NonOpioid),sd(all_cur_pain_NonOpioid,na.rm = TRUE),min(all_cur_pain_NonOpioid,na.rm = TRUE),max(all_cur_pain_NonOpioid,na.rm = TRUE))
      # what's the range and the standard deviation on the pain so we can get error bars
      cur_avg_sleep_qual <- mean(all_cur_sleep_quals,na.rm = TRUE)
      stats_sleep_quals[1,cur_list_idx] <- cur_avg_sleep_qual # average sleep quality
      stats_sleep_quals[2,cur_list_idx] <- sum(cur_avg_sleep_qual < all_cur_sleep_quals,na.rm=TRUE) # num of entries above average
      stats_sleep_quals[3,cur_list_idx] <- sum(cur_avg_sleep_qual > all_cur_sleep_quals,na.rm=TRUE) # num of entries below average
      stats_sleep_quals[4,cur_list_idx] <- sum(all_cur_diary_lengths) # total # of entries
      stats_sleep_quals[5,cur_list_idx] <- sum(all_cur_diary_lengths)/length(cur_list) # average # of entries
      stats_sleep_quals[6,cur_list_idx] <- ceiling(stats_sleep_quals[3,cur_list_idx]/length(cur_list)) # average # of nights of bad sleep
      #stats_sleep_quals[6,cur_list_idx] <- sum(rle(cur_avg_sleep_qual > all_cur_sleep_quals)$length>1&rle(cur_avg_sleep_qual > all_cur_sleep_quals)$values)/length(cur_list) # average # of consecutive nights below average
      stats_sleep_quals[7,cur_list_idx] <- sd(all_cur_sleep_quals,na.rm = TRUE) # standard deviation of sleep quality
    } # end loop over partitions
  }
  
  # statistics for HF_C_Drug (interesting in fig 111 cause of the dip) in:
  # stats_on_drug_pain[,3,]
  
  output<-list(pain_response_to_sleep,stats_sleep_quals,stats_on_opioid_pain,stats_on_nonopioid_pain,stats_on_drugfree_pain)
  return(output)
}

generate_pain_response_curves_paper <- function(temp_data,possible_ID_lists,num_bins,no_drug_influence = FALSE){
  
  # note on the output
  # if there is no influence of drugs considered (i.e., no_drug_influence = TRUE) the you want to look in 
  # the output pain_response_to_sleep[partition_idx+1,cur_list_idx,1] since pain_response_to_sleep[partition_idx+1,cur_list_idx,2] 
  # will be all -10s (see lines 330-336 )
  
  # compute the width of the bins
  width_of_bins <- 100/num_bins
  
  # generate arrays to store outputs
  population_diary_length <- array(NA,dim=c(1,length(possible_ID_lists),2))
  
  stats_sleep_quals <- matrix(NA,nrow=7,ncol=length(possible_ID_lists))
  row.names(stats_sleep_quals) <- c("Average sleep quality","Nights above sleep average","Nights below sleep average","Total # of entries","Average # of entries","Average # of bad sleep nights","Standard deviation")
  colnames(stats_sleep_quals) <- possible_ID_lists
  
  pain_response_to_sleep <- array(NA, dim=c(num_bins,length(possible_ID_lists),3)) 
  row.names(pain_response_to_sleep) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(pain_response_to_sleep) <- possible_ID_lists
  
  stats_on_drugfree_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  #dimnames(stats_on_drugfree_pain)[3] <- c("Sample Size",Std. Dev","Min pain","Max Paid")
  stats_on_opioid_pain <- stats_on_drugfree_pain
  stats_on_nonopioid_pain <- stats_on_drugfree_pain
  
  row.names(stats_on_drugfree_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_drugfree_pain) <- possible_ID_lists
  row.names(stats_on_opioid_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_opioid_pain) <- possible_ID_lists
  row.names(stats_on_nonopioid_pain) <- paste0("Above ",width_of_bins*seq(num_bins-1,0))
  colnames(stats_on_nonopioid_pain) <- possible_ID_lists
  
  # main code
  for (cur_list_idx in seq(1,length(possible_ID_lists))){ # for each column in table
    all_cur_sleep_quals <- c()  # these only needs to be computed for each subpopulation
    all_cur_diary_lengths <- c() # these only needs to be computed for each subpopulation
    for (partition_idx in seq(0,num_bins-1)){ # for each row in table
      all_cur_pain_DrugFree <- c()
      all_cur_pain_NonOpioid <- c()
      all_cur_pain_Opioid <- c()
      cur_list <- get(possible_ID_lists[cur_list_idx])
      for (cur_ID in cur_list){ # for each patient in subpopulation
        # further processes/prepares the data
        cur_rows <- temp_data[,"ID#"] %in% cur_ID
        cur_diary_length <- sum(cur_rows) 
        cur_cur_data <- temp_data[cur_rows,]
        num_entries <- dim(cur_cur_data)[1]
        # find first entry where pain or sleep is reported
        non_na_entries <- !apply(is.na(cur_cur_data[,c("PainYNSev","SleepQ")]),FUN = all,MARGIN = 1) # checks if both Pain and Sleep are NA for each entry
        first_non_na_entry <- as.integer(which(non_na_entries)[1])
        actual_entries <- seq(first_non_na_entry,num_entries)
        cur_data <- cur_cur_data[actual_entries,]
        if (partition_idx == 0){ # first iteration of the "for each row" loop
          key <- 100-width_of_bins <= cur_data$SleepQ & cur_data$SleepQ <= 100 # same as line 324 except right is <=
          # these only needs to be computed for each subpopulation (on the first iteration)
          non_na_sleep_temp<- cur_data[cur_data$MorEve == 0,"SleepQ"]
          non_na_sleep_data <- non_na_sleep_temp[!is.na(non_na_sleep_temp)]
          all_cur_sleep_quals <- c(all_cur_sleep_quals,non_na_sleep_data)
          all_cur_diary_lengths <- c(all_cur_diary_lengths,length(non_na_sleep_data)) # sum the non NA morning entries
        }else{
          key <- 100-width_of_bins*(partition_idx+1) <= cur_data$SleepQ & cur_data$SleepQ < 100-width_of_bins*(partition_idx) # same as line 317
        }
        pain_to_avg_idxs <- as.vector(na.omit(seq(1,length(key))[key]))+1 # index for pain the next day
        if (no_drug_influence == TRUE){
          # commented steps aren't needed when there's no drug influence
          #drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          #cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          #drugfree_day_pain_subidx <- cur_temp == 0
          #drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,-10)
          all_cur_pain_NonOpioid <- all_cur_pain_DrugFree
          all_cur_pain_Opioid <- c(all_cur_pain_Opioid,cur_data[pain_to_avg_idxs,"PainYNSev"])
        }else{ # split into drug and drug free
          drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] 
          drugfree_day_pain_subidx <- cur_temp == 0
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,cur_data[pain_to_avg_idxs[drugfree_day_pain_subidx],"PainYNSev"])
          drug_day_pain_subidx <- cur_temp == 1
          NonOpioid_temp <- cur_data[drugs_to_check_idxs,c("Analgesic")] 
          Opioid_temp <- cur_data[drugs_to_check_idxs,c("Narcotic")] 
          were_drugs_opioids_subidx <- Opioid_temp == 1
          were_drugs_NonOpioids_subidx <- NonOpioid_temp == 1
          #were_drugs_opioids_subidx <- cur_data[drugs_to_check_idxs,c("PainMed")] %in% c("Tramadol","Morphine","Oxycontin","Lortab","Tylenol With Codeine")
          all_cur_pain_Opioid <- c(all_cur_pain_Opioid,cur_data[pain_to_avg_idxs[drug_day_pain_subidx & were_drugs_opioids_subidx],"PainYNSev"])
          all_cur_pain_NonOpioid <- c(all_cur_pain_NonOpioid,cur_data[pain_to_avg_idxs[drug_day_pain_subidx & were_drugs_NonOpioids_subidx],"PainYNSev"])
        }
      } # end loop over IDs
      pain_response_to_sleep[partition_idx+1,cur_list_idx,3] <- mean(all_cur_pain_NonOpioid,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,2] <- mean(all_cur_pain_DrugFree,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,1] <- mean(all_cur_pain_Opioid,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      stats_on_drugfree_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_DrugFree),sd(all_cur_pain_DrugFree,na.rm = TRUE),min(all_cur_pain_DrugFree,na.rm = TRUE),max(all_cur_pain_DrugFree,na.rm = TRUE))
      stats_on_opioid_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_Opioid),sd(all_cur_pain_Opioid,na.rm = TRUE),min(all_cur_pain_Opioid,na.rm = TRUE),max(all_cur_pain_Opioid,na.rm = TRUE))
      stats_on_nonopioid_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_NonOpioid),sd(all_cur_pain_NonOpioid,na.rm = TRUE),min(all_cur_pain_NonOpioid,na.rm = TRUE),max(all_cur_pain_NonOpioid,na.rm = TRUE))
      # what's the range and the standard deviation on the pain so we can get error bars
      cur_avg_sleep_qual <- mean(all_cur_sleep_quals,na.rm = TRUE)
      stats_sleep_quals[1,cur_list_idx] <- cur_avg_sleep_qual # average sleep quality
      stats_sleep_quals[2,cur_list_idx] <- sum(cur_avg_sleep_qual < all_cur_sleep_quals,na.rm=TRUE) # num of entries above average
      stats_sleep_quals[3,cur_list_idx] <- sum(cur_avg_sleep_qual > all_cur_sleep_quals,na.rm=TRUE) # num of entries below average
      stats_sleep_quals[4,cur_list_idx] <- sum(all_cur_diary_lengths) # total # of entries
      stats_sleep_quals[5,cur_list_idx] <- sum(all_cur_diary_lengths)/length(cur_list) # average # of entries
      stats_sleep_quals[6,cur_list_idx] <- ceiling(stats_sleep_quals[3,cur_list_idx]/length(cur_list)) # average # of nights of bad sleep
      #stats_sleep_quals[6,cur_list_idx] <- sum(rle(cur_avg_sleep_qual > all_cur_sleep_quals)$length>1&rle(cur_avg_sleep_qual > all_cur_sleep_quals)$values)/length(cur_list) # average # of consecutive nights below average
      stats_sleep_quals[7,cur_list_idx] <- sd(all_cur_sleep_quals,na.rm = TRUE) # standard deviation of sleep quality
    } # end loop over partitions
  }
  
  # statistics for HF_C_Drug (interesting in fig 111 cause of the dip) in:
  # stats_on_drug_pain[,3,]
  
  output<-list(pain_response_to_sleep,stats_sleep_quals,stats_on_opioid_pain,stats_on_nonopioid_pain,stats_on_drugfree_pain)
  return(output)
}
