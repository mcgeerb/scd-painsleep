function [dose_times1,dose_times2,dose_times3,drug_info] = get_dose_times(drug_info,la_drugtimes,sa_drugtimes,no_drugtimes,merge_all_drugs,drugs_to_include,common_drug_info,drug_threshold)
% This function takes raw drug time info, and it returns useful drug time info 
% If merge_all_drugs is 1, then only send back one dose_time vector
% Use drugs_to_include indicator vector to send back only desired drug_times
% Use drug_threshold to exclude drugs taken infrequently

% if user wants to exclude certain drugs, delete those drug times
if drugs_to_include(1)==0
    la_drugtimes = [];
end
if drugs_to_include(2)==0
    sa_drugtimes = [];
end
if drugs_to_include(3)==0
    no_drugtimes = [];
end

% if user wants to merge all drugs, return combined drug times
if merge_all_drugs > 0
    dose_times1 = sort([la_drugtimes; sa_drugtimes; no_drugtimes]);
    dose_times2 = zeros(0,1);
    dose_times3 = zeros(0,1);
    num_drugs_taken = (~isempty(dose_times1))+(~isempty(dose_times2))+(~isempty(dose_times3));
    % check if patient did not take any drugs, send empty vector
    if num_drugs_taken < drug_threshold
        drug_info = zeros(0,2);
    else
        drug_info = common_drug_info;
    end
% if user does not want to merge drugs, put drugs in useful order    
else
    % number of drugs doses of each class taken
    la_numdrugs = length(la_drugtimes); dose_times1 = la_drugtimes;
    sa_numdrugs = length(sa_drugtimes); dose_times2 = sa_drugtimes;
    no_numdrugs = length(no_drugtimes); dose_times3 = no_drugtimes;
    
    % if no NO drugs are taken, remove them from list
    if no_numdrugs < drug_threshold
        drug_info(3,:) = [];
        dose_times3 = zeros(0,1);
    end
    % if no SA drugs are taken, remove them from list and reorder last two
    % drug classes
    if sa_numdrugs < drug_threshold
        drug_info(2,:) = [];
        % shift untaken sa drug to last spot
        dose_times2 = dose_times3;
        dose_times3 = zeros(0,1);
    end
    % if no LA drugs are taken, remove them from list and reorder all three
    % drug classes
    if la_numdrugs < drug_threshold
        drug_info(1,:) = [];
        % shift untaken la drug to last spot
        dose_times1 = dose_times2;
        dose_times2 = dose_times3;
        dose_times3 = zeros(0,1);
    end
end

% check if number of drug times exceeds threshold (otherwise delete)


end

