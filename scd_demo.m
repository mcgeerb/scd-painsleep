

%% This script finds parameters to fit model to patient data
clear
close all

save_it = input('Do you want to save the results? (0 or 1)');


% seed random number generator
seed = 123;

% Add directories to search path
addpath ./util
addpath ./plotting
addpath ./results

all_subpopulations_for_titles = {'Synth\_Simulation'};
full_name_for_titles = {[],'adolescent','child'};

% number of LHS samples
M=100;

saved_fit_params = nan(length(all_subpopulations_for_titles),2);

for cur_subpopulation = 1
    
    
    rng(seed);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % data and drug info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % indicator of drug classes to include in fitting (LA,SA,NO)
    drugs_to_include = [1 0 0];
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % user-specified patient info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % (previously) fixed k0 for patients (how fast patients rebound from reduced or increased pain, absent drugs)
    % Clifton et al. took rebound half life to be half an hour, we use this as an initial condition
    fixed_k0 = log(2)/8;
    
    unmitigated_pain = 1e-10;
    beta_val = 15;%;100*.23;
    
    num_accum = 1;
    
    % for plotting
    rectangles_or_nah=1;
    bad_sleep_or_nah=0;
    model_version = 'OG';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % scheme options
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % how to optimize (locally via fmincon or globally via simulated annealing)
    scheme = 'fmincon';
    % threshold for drug dose times to be included in model (default is 1)
    drug_threshold = 1;
    % tolerance on how long sleep should impact pain
    sleepqual_tol = 36; % was 18 for a while...why? when?
    % all parameters: [P0, u, eps, k0, k1, k2, k3, beta]
    ki_to_include = 5:7; % all possible drug kinetic parameters
    ki_to_include(~drugs_to_include) = []; % don't fit drug kinetic parameters of drugs not taken/included
    params_to_fit = [4,8];  % subset of 1:8
    
    % indicator to merge all drug classes together (1 for merge, 0 for not)
    merge_all_drugs = 0; common_drug_info = [log(0.5)/(-4.0),1];
    % time resolution for integration and plotting (0.5 is half hour)
    time_res = 0.5;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% run through each patient's data
    
    % load patient data into convenient form (just useful info on specified time)
    
    diary_times = [32,44,56,68,80,92,104,116,128,140]';
    diary_pain = 100*rand(1,10)';
    diary_sleep = 70+20*rand(1,10)';
    diary_drug_use = randi([0 1],10,3);
    diary_mor_eve = mod(1:10,2)';
    patient_data = [diary_times diary_pain diary_sleep diary_drug_use diary_mor_eve];
    
    % time vector (add an extra hour to end for interp1 - it freaks out about rounding errors)
    tvec = (patient_data(1,1):time_res:(patient_data(end,1)+1))';
    evening_entries = (patient_data(:,end) == 1);
    % pain report contains time and pain info from patient (remove times when patient does not report actual pain)
    pain_report_real = patient_data(evening_entries,1:2)'; pain_report_real(:,isnan(pain_report_real(2,:))) = [];
    % sleep report contains time and pain info from patient (remove times when patient does not report actual pain)
    sleep_report_real = patient_data(~evening_entries,[1,3])'; sleep_report_real(:,isnan(sleep_report_real(2,:))) = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Generate synthetic sleep profile using subpopulation stats and times from the representative patient
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    just_the_sleep_times = sleep_report_real(1,:);
    
    sq_mu = mean(diary_sleep);
    
    tresday_avg_sq = movmean(just_the_sleep_times,[num_accum 0],'Endpoints','fill'); %padding the ends of the input with NaN.
    bad_sleep_times = just_the_sleep_times(tresday_avg_sq<sq_mu);%,1);
    
    % Simulated drug use
    % Long acting (t_halflife = 10 hr); Short acting (t_halflife = 4 hr); Non-opiod (t_halflife = 4 hr)
    drug_info = [log(0.5)/(-10.0),1; log(0.5)/(-4.0),1; log(0.5)/(-4.0),1];
    la = patient_data(:,4); % the sizing/dimension alignment between diffpain, patient data, etc isn't perfect...
    sa = patient_data(:,5); no = patient_data(:,6);
    % % drug time vectors for each class of drug (empty vector if no drugs taken)
    la_drugtimes = patient_data(la>0,1); sa_drugtimes = patient_data(sa>0,1); no_drugtimes = patient_data(no>0,1);
    
    [dose_times1,dose_times2,dose_times3,drug_info] = get_dose_times(drug_info,la_drugtimes,sa_drugtimes,no_drugtimes,merge_all_drugs,drugs_to_include,common_drug_info,drug_threshold);
    
    
    fprintf('Sampling to find initial parameters... \n')
    init_params = [unmitigated_pain,fixed_k0,beta_val,sleepqual_tol];
    xhat_init = init_params(2:3);
    rnge_p = [0 1; 1 100];
    
    lb = rnge_p(:,1)';                          % Lower bounds
    ub = rnge_p(:,2)';                          % Upper bounds
    L = lhsdesign(M,size(rnge_p,1),'criterion','correlation');
    all_params = bsxfun(@plus,lb,bsxfun(@times,L,(ub-lb))); 
    
    obj_vals = Inf*ones(M,1);
    all_fit_params = [];
    
    
    for cur_idx = 1:M
        temp_params = init_params;
        temp_params(2:3) = all_params(cur_idx,:);
        [~,~,obj_vals(cur_idx)] = eval_objective_at_params(tvec,dose_times1,dose_times2,dose_times3,pain_report_real,patient_data,drug_info,drugs_to_include,bad_sleep_times,sleep_report_real,temp_params,params_to_fit);
    end
    
    
    [min_obj,min_idx]=min(obj_vals);
    fprintf('Minimum objective value: \n')
    format long g
    disp(num2str(obj_vals(min_idx)))
    fprintf('\n')
    temp_params = init_params;
    fprintf('Initial params \n')
    format long g
    disp(all_params(min_idx,:))
    temp_params(2:3) = all_params(min_idx,:);
    params = [temp_params(1) NaN temp_params(2) drug_info(1:end-1) temp_params(3:end)]'; % work around on 5/26
    figure
    plot_model_r01_talk(tvec,params,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,['LHS: ',all_subpopulations_for_titles{cur_subpopulation}],drugs_to_include,rectangles_or_nah,bad_sleep_or_nah,num_accum,model_version,0);
    if save_it == 1
        saveas(gcf, ['./plotting/Fit_To_PRC_Data_for_',all_subpopulations_for_filenames{cur_subpopulation},'via_LHS_',num2str(num_accum),'_',num2str(M),'_',num2str(sleepqual_tol)], 'pdf') %Save figure
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Start simulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if contains(scheme,'sa')
        [params,err,obj_val] = fit_patient_params_via_sa(tvec,dose_times1,dose_times2,dose_times3,pain_report_real,patient_data,drug_info,drugs_to_include,bad_sleep_times,sleep_report_real,temp_params,params_to_fit);
    else
        [params,err,obj_val] = fit_patient_params_via_fmincon(tvec,dose_times1,dose_times2,dose_times3,pain_report_real,patient_data,drug_info,drugs_to_include,bad_sleep_times,sleep_report_real,temp_params,params_to_fit);
    end
    fprintf('Final objective value: \n')
    format long g
    disp(num2str(obj_val))
    fprintf('\n')
    params_fit = params_to_fit - 1;
    % best fit patient info
    patient_info = [patient_data(1,2),params(1:length(params)-1)']; % cuts off that unnecessary, repeated residual
    
    new_k0 = params(3);
    new_beta = params(end-1);
    fit_params = [new_k0, new_beta];
    
    figure
    plot_model_r01_talk(tvec,params,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,['Model fit to average ',full_name_for_titles{cur_subpopulation},' pain response'],drugs_to_include,rectangles_or_nah,bad_sleep_or_nah,num_accum,model_version,0);
    if save_it == 1
        saveas(gcf, ['./plotting/Fit_To_Synth_Data_for_',all_subpopulations_for_filenames{cur_subpopulation},'via_fmincon_',num2str(num_accum),'_',num2str(M),num2str(sleepqual_tol)], 'png') %Save figure
    end
    disp('Fit params')
    format long g
    disp(fit_params)
    
    
    
    saved_fit_params(cur_subpopulation,:) = fit_params;
    
end

if save_it == 1
    filename = ['./results/Subpopulation_parameter_fit_sqtol',num2str(sleepqual_tol),'.mat'];
    save(filename,'saved_fit_params','num_accum','sleepqual_tol')
    disp('Saved...')
end
