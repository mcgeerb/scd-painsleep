function err = est_err_via_leastsquares(xhat,all_parameters,tvec,drug_info,dose_times1,dose_times2,dose_times3,drugs_to_include,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,params_to_fit)
% synopsis: this function was named est_err3 / it's the same as the previous est_err2
% but it doesn't impose nonegativity at this level. The nonnegativity constraint was added into fmincon

% subset the all_parameters vector and create patient info according to input xhat
patient_info = all_parameters; % always length 8 to start
patient_info(params_to_fit) = xhat; % puts the parameters being varied in their corresponding spot
if any(drugs_to_include==0) % are any drugs not included
    remove_k_idx = find(~drugs_to_include)+4; % drugs are in spaces 5,6, and 7
    patient_info(remove_k_idx) = []; % gets rid of placeholder for missing drugs. continues as previously done now.
end

% run simulation with provided parameters
%    original setup:
%report = run_painsim_drugs3_ode_sleep(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol);
%report_times = report(1,:);
%real_pain = report(2,:);
%sim_pain = report(3,:);
%    new setup: now circumventing 'run_painsim' and doing interpolation here
[sim_times,sim_pain_init] = pain_sim_core(tvec,patient_info,drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
report_times = pain_report_real(1,:);
real_pain = pain_report_real(2,:);
sim_pain = interp1(sim_times,sim_pain_init,report_times);
% calculate pain prediction error
err = sqrt(1/(length(report_times)-1)*sum((real_pain-sim_pain).^2));
end


