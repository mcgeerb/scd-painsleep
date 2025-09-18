function proc_data = process_pain_entries(patient_data)
% create proc_data the same size as patient data, gonna
% replace all pain entries with max over that day

% kinda need to know the first and last entry
first_entry = patient_data(1,end); % morning or evening
last_entry = patient_data(end,end); % morning or evening
tot_entries = length((patient_data(:,end) == 1));
if first_entry == 0
    test = mod(0:(tot_entries-1),2); % make vector of 0 and 1s
else
    test = mod(1:tot_entries,2); % make vector of 0 and 1s
end

% initialize proc_data
proc_data = patient_data(:,1:6); proc_data(:,7) = test'; % 'fixed' on 5/26 proc_data(:,end) = test';

% find maximum for each day

if first_entry == 1 % started with evening
    if last_entry == 0 % ended with morning
        proc_data(1,2) = patient_data(1,2);
        proc_data(end,2) = proc_data(end,2);
        for cur_idx=2:2:(tot_entries-2)
            proc_data([cur_idx cur_idx+1],2) = max(patient_data(cur_idx,2),patient_data(cur_idx+1,2));
        end
    else % last_entry == 1 ended with evening
        proc_data(1,2) = patient_data(1,2);
        for cur_idx=2:2:(tot_entries-1)
            proc_data([cur_idx cur_idx+1],2) = max(patient_data(cur_idx,2),patient_data(cur_idx+1,2));
        end
        
    end
else % first_entry == 0 / started with morning
    if last_entry == 0 % ended with morning
        proc_data(end,2) = proc_data(end,2);
        for cur_idx=1:2:(tot_entries-2)
            proc_data([cur_idx cur_idx+1],2) = max(patient_data(cur_idx,2),patient_data(cur_idx+1,2));
        end
    else % last_entry == 1 / ended with evening
        for cur_idx=1:2:(tot_entries-1)
            proc_data([cur_idx cur_idx+1],2) = max(patient_data(cur_idx,2),patient_data(cur_idx+1,2));
        end
    end
end
end



