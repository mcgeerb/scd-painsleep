function err = est_err_via_rectangle(xhat,all_parameters,tvec,drug_info,dose_times1,dose_times2,dose_times3,drugs_to_include,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,params_to_fit)
% synopsis: this function measures whether the simulation is in the "pain rectangle"
% it doesn't impose nonegativity at this level. The nonnegativity constraint was added into fmincon

% subset the all_parameters vector and create patient info according to inputs
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
%    new setup: now circumventing 'run_painsim' and its interpolation
[~,sim_pain_init] = pain_sim_core(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
report_times = pain_report_real(1,:);
real_pain = pain_report_real(2,:);
pain_accur = realmax*ones(1,length(report_times)-1); % pain_compar
% loop over reported times
for cur_subinterval_idx = 1:(length(report_times)-1)
    % find which entries in tvec correspond to report times
    idx1 = find(tvec == report_times(cur_subinterval_idx));
    idx2 = find(tvec == report_times(cur_subinterval_idx+1));
    % restrict sim_pain_init to between those indices
    cur_pain_sims = sim_pain_init(idx1:idx2);
    max_pain_reported = max(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1));
    min_pain_reported = min(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1));
    % compute how close the simulated pain ever got close to the pain rectangle for current 12 hour window
    if any((cur_pain_sims <= max_pain_reported)) % check if the simulated pain is below the top of rectangle
        if any((cur_pain_sims >= min_pain_reported)) % check if the simulated pain is above the bottom of rectangle
            pain_accur(cur_subinterval_idx) = 0;
        else % the simulated pain is below the bottom of rectangle
            cur_dists = sqrt((min_pain_reported*ones(size(cur_pain_sims))-cur_pain_sims).^2);
            pain_accur(cur_subinterval_idx) = min(cur_dists);
        end
    else % the simulated pain is above the top of rectangle
        cur_dists = sqrt((cur_pain_sims-max_pain_reported*ones(size(cur_pain_sims))).^2);
        pain_accur(cur_subinterval_idx) = min(cur_dists);
    end
    %         if any(abs(cur_pain_sims - max(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1)))<0.1) % check if the simulated pain ever got close to the maximum pain in that 12 hour window
    %             find (cur_pain_sims - max(real_pain(idx1), real_pain(idx2))<0.1,'first') % where did it happen
    %             pain_accur(cur_subinterval_idx) = 1; % mark that it happened
    %         end
end
%err = sum(pain_accur)/length(pain_accur);
err = sum(pain_accur);   % maybe weight towards the nonzero rectangles
end