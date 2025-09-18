#possible_ID_lists <- c("all_IDs","hydroxy_free_A_IDs","hydroxy_free_C_IDs")

generate_pain_response_curves <- function(possible_ID_lists,num_bins,no_drug_influence = NULL,save_it = NULL){
  population_diary_length <- array(NA,dim=c(1,length(possible_ID_lists),2))
  
  width_of_bins <- 100/num_bins
  
  stats_sleep_quals <- matrix(NA,nrow=5,ncol=length(possible_ID_lists))
  row.names(stats_sleep_quals) <- c("Average sleep quality","Nights above sleep average","Nights below sleep average","Total # of entries","Standard deviation")
  colnames(stats_sleep_quals) <- possible_ID_lists
  
  pain_response_to_sleep <- array(NA, dim=c(num_bins,length(possible_ID_lists),2)) 
  row.names(pain_response_to_sleep) <- paste0("Above ",10*seq(num_bins-1,0))
  colnames(pain_response_to_sleep) <- possible_ID_lists
  
  stats_on_drugfree_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  stats_on_drug_pain <- array(NA, dim=c(num_bins,length(possible_ID_lists),4)) 
  row.names(stats_on_drugfree_pain) <- paste0("Above ",10*seq(num_bins-1,0))
  colnames(stats_on_drugfree_pain) <- possible_ID_lists
  row.names(stats_on_drug_pain) <- paste0("Above ",10*seq(num_bins-1,0))
  colnames(stats_on_drug_pain) <- possible_ID_lists
  
  for (cur_list_idx in seq(1,length(possible_ID_lists))){ # each column in table
    all_cur_sleep_quals <- c()  # these only needs to be computed for each subpopulation
    all_cur_diary_lengths <- c() # these only needs to be computed for each subpopulation
    for (partition_idx in seq(0,num_bins-1)){ # each row in table
      all_cur_pain_DrugFree <- c()
      all_cur_pain_Drug <- c()
      for (cur_ID in get(possible_ID_lists[cur_list_idx])){ # each patient in subpopulation
        cur_rows <- temp_data[,"ID#"] %in% cur_ID
        cur_diary_length <- sum(cur_rows) #nrow(temp_data[cur_rows,])
        cur_cur_data <- temp_data[cur_rows,]
        num_entries <- dim(cur_cur_data)[1]
        # find first entry where pain or sleep is reported
        non_na_entries <- !apply(is.na(cur_cur_data[,c("PainYNSev","SleepQ")]),FUN = all,MARGIN = 1) # checks if both Pain and Sleep are NA for each entry
        first_non_na_entry <- as.integer(which(non_na_entries)[1])
        actual_entries <- seq(first_non_na_entry,num_entries)
        cur_data <- cur_cur_data[actual_entries,]
        if (partition_idx == 0){
          key <- 100-width_of_bins <= cur_data$SleepQ & cur_data$SleepQ <= 100
          # these only needs to be computed for each subpopulation
          non_na_sleep_temp<- cur_data[cur_data$MorEve == 0,"SleepQ"]
          non_na_sleep_data <- non_na_sleep_temp[!is.na(non_na_sleep_temp)]
          all_cur_sleep_quals <- c(all_cur_sleep_quals,non_na_sleep_data)
          all_cur_diary_lengths <- c(all_cur_diary_lengths,length(non_na_sleep_data)) # sum the non NA moring entries
        }else{
          key <- 100-width_of_bins*(partition_idx+1) <= cur_data$SleepQ & cur_data$SleepQ < 100-width_of_bins*(partition_idx)
        }
        pain_to_avg_idxs <- as.vector(na.omit(seq(1,length(key))[key]))+1 # index for pain the next day
        if (no_drug_influence == TRUE){
          #drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          #cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] #,"OtherMDYN")]
          #drugfree_day_pain_subidx <- cur_temp == 0
          #drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,-10)
          all_cur_pain_Drug <- c(all_cur_pain_Drug,cur_data[pain_to_avg_idxs,"PainYNSev"])
        }else{ # split into drug and drug free
          drugs_to_check_idxs <- pain_to_avg_idxs #sort(c(pain_to_avg_idxs,pain_to_avg_idxs-1)) # index for when to check for drugs 
          cur_temp <- cur_data[drugs_to_check_idxs,c("PainMedYN")] #,"OtherMDYN")]
          drugfree_day_pain_subidx <- cur_temp == 0
          drug_day_pain_subidx <- cur_temp == 1
          all_cur_pain_DrugFree <- c(all_cur_pain_DrugFree,cur_data[pain_to_avg_idxs[drugfree_day_pain_subidx],"PainYNSev"])
          all_cur_pain_Drug <- c(all_cur_pain_Drug,cur_data[pain_to_avg_idxs[drug_day_pain_subidx],"PainYNSev"])
        }
      } # end loop over IDs
      pain_response_to_sleep[partition_idx+1,cur_list_idx,1] <- mean(all_cur_pain_DrugFree,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      pain_response_to_sleep[partition_idx+1,cur_list_idx,2] <- mean(all_cur_pain_Drug,na.rm=TRUE) # median(all_cur_pain,na.rm=TRUE)
      stats_on_drugfree_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_DrugFree),sd(all_cur_pain_DrugFree,na.rm = TRUE),min(all_cur_pain_DrugFree,na.rm = TRUE),max(all_cur_pain_DrugFree,na.rm = TRUE))
      stats_on_drug_pain[partition_idx+1,cur_list_idx,] <- c(length(all_cur_pain_Drug),sd(all_cur_pain_Drug,na.rm = TRUE),min(all_cur_pain_Drug,na.rm = TRUE),max(all_cur_pain_Drug,na.rm = TRUE))
      # what's the range and the standard deviation on the pain so we can get error bars
      cur_avg_sleep_qual <- mean(all_cur_sleep_quals,na.rm = TRUE)
      stats_sleep_quals[1,cur_list_idx] <- cur_avg_sleep_qual
      stats_sleep_quals[2,cur_list_idx] <- sum(cur_avg_sleep_qual < all_cur_sleep_quals,na.rm=TRUE)
      stats_sleep_quals[3,cur_list_idx] <- sum(cur_avg_sleep_qual > all_cur_sleep_quals,na.rm=TRUE)
      stats_sleep_quals[4,cur_list_idx] <- sum(all_cur_diary_lengths)
      stats_sleep_quals[5,cur_list_idx] <- sd(all_cur_sleep_quals,na.rm = TRUE)
    } # end loop over partitions
  }
  
  # statistics for HF_C_Drug (interesting in fig 111 cause of the dip) in:
  # stats_on_drug_pain[,3,]
  if (save_it == TRUE){
    file_path_stats <- paste0("~/Dropbox/Profession/Research/SickleCell/modeling/code/results/stats_on_sleepquality.txt")
    write.table(stats_sleep_quals, file = file_path_stats, sep = "\t",row.names = TRUE, col.names = TRUE)
    
    file_path_pain_response_drug <- paste0("~/Dropbox/Profession/Research/SickleCell/modeling/code/results/pain_response_curve_drug.txt")
    write.table(pain_response_to_sleep[,,2], file = file_path_pain_response_drug, sep = "\t",row.names = TRUE, col.names = TRUE)
    
    file_path_pain_response_drugfree <- paste0("~/Dropbox/Profession/Research/SickleCell/modeling/code/results/pain_response_curve_drugfree.txt")
    write.table(pain_response_to_sleep[,,1], file = file_path_pain_response_drugfree, sep = "\t",row.names = TRUE, col.names = TRUE)
  }
  output<-list(pain_response_to_sleep,stats_sleep_quals,stats_on_drug_pain,stats_on_drugfree_pain)
  return(output)
}
