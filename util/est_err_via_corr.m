function err = est_err_via_corr(xhat,all_parameters,tvec,drug_info,dose_times1,dose_times2,dose_times3,drugs_to_include,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,params_to_fit)
% synopsis: this function measures the correlation between the actual categorization of pain
% and the categoriztion of the simulation
% it doesn't impose nonegativity at this level. The nonnegativity constraint was added into fmincon

% subset the all_parameters vector and create patient info
patient_info = all_parameters; % always length 8 to start
patient_info(params_to_fit) = xhat; % puts the parameters being varied in their corresponding spot
if any(drugs_to_include==0) % are any drugs not included
    remove_k_idx = find(~drugs_to_include)+4; % drugs are in spaces 5,6, and 7
    patient_info(remove_k_idx) = []; % gets rid of placeholder for missing drugs. continues as previously done now.
end

%original setup:
%     % run simulation with provided parameters
%     report = run_painsim_drugs3_ode_sleep(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol);
%     report_times = report(1,:);
%     real_pain = report(2,:);
%     sim_pain = report(3,:);

%    new setup: now circumventing 'run_painsim' and doing interpolation here
[sim_times,sim_pain_init] = pain_sim_core(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
report_times = pain_report_real(1,:);
real_pain = pain_report_real(2,:);
sim_pain = interp1(sim_times,sim_pain_init,report_times);

% NOTE: 11/02/2023 IDK WHY THIS LOOP IS HERE. IT'S COMPUTING A MEASURE OF ACCURACY
%    new setup: now circumventing 'run_painsim' and its interpolation
% [~,sim_pain_init] = pain_sim_interventions3_sleep(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
% report_times = pain_report_real(1,:);
% real_pain = pain_report_real(2,:);
% sim_pain = zeros(size(real_pain)); % not sure about zeros here, maybe NaN*ones() --- sim pain could end up kinda hodgepodge
% pain_accur = zeros(1,length(report_times)-1); % pain_compar
% go through a loop
% for cur_subinterval_idx = 1:(length(report_times)-1)
%     % find which entries in tvec correspond to report times
%     idx1 = find(tvec == report_times(cur_subinterval_idx));
%     idx2 = find(tvec == report_times(cur_subinterval_idx+1));
%     % restrict sim_pain_init to between those indices
%     cur_pain_sims = sim_pain_init(idx1:idx2);
%     % check if the simulated pain ever got close to the maximum pain in that 12 hour window
%     if any((cur_pain_sims >= min(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1))) & (cur_pain_sims <= max(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1)))) % check if the simulated pain ever got close to the maximum pain in that 12 hour window
%         idx_sim = find((cur_pain_sims >= min(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1))) & (cur_pain_sims <= max(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1))),1); % where did it happen
%         sim_pain(cur_subinterval_idx) = cur_pain_sims(idx_sim); % closest value to the band
%         pain_accur(cur_subinterval_idx) = 1; % mark that it happened
%     end
%     
% end

% can happen after either setup
%movmean(sim_pain,[1 0],'Endpoints','fill') % IDK WHAT THIS IS FOR
categ_sim = categorize_pain(sim_pain);
categ_real = categorize_pain(real_pain);
%sum(categ_sim == categ_real)/length(categ_real);
% false positives
rho_pain = corrcoef(categ_sim,categ_real); % this should be a 2x2 matrix
err = 1-rho_pain(1,2);
end
