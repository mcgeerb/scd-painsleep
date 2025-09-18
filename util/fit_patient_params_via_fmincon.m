 function [params,err,obj_val] = fit_patient_params_via_fmincon(tvec,dose_times1,dose_times2,dose_times3,pain_report_real,patient_data,drug_info,drugs_to_include,bad_sleep_times,sleep_report_real,init_params,params_to_fit)
% This function uses fmincon to find best fit of model to patient data.
% Parameters to vary are specified via "params_to_fit"

% note the form of the initial parameter vector
% init_params = [unmitigated_pain,fixed_k0,beta,sleepqual_tol];

% matrix to hold predicted patient parameters for each search
% patient_info is always the length 8 for now. 
if any(drugs_to_include)
    patient_info = [patient_data(1,2),init_params(1),0,init_params(2),drug_info(1)*ones(1,length(drugs_to_include)).*drugs_to_include,init_params(3)]; 
else
    patient_info = [patient_data(1,2),init_params(1),0,init_params(2),(0.25*randn(1,length(drugs_to_include))+0.75).*drugs_to_include,init_params(3)]; 
end
sleepqual_tol = init_params(4);

% choose method for estimating error in simulation
%err_used = @est_err_via_leastsquares;
%err_used = @est_err_via_mse;
%err_used = @est_err_via_rmse;
err_used = @est_err_via_weighted_ls;
%err_used = @est_err_via_rectangle;
%err_used = @est_err_via_zone_hit_target; %TO DO: 3/19/24
%err_used = @est_err_via_corr;

% define objective function for the minimizer
func_handle = @(xhat)(err_used(xhat,patient_info,tvec,drug_info,dose_times1,dose_times2,dose_times3,drugs_to_include,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,params_to_fit));

% get initial values for parameters to be fit
xhat_init = patient_info(params_to_fit); 

fprintf('FMINCON activate!!! \n \n')
opts = optimoptions('fmincon','Display','iter-detailed','TolX',1e-8,'TolFun',1e-8,'MaxIterations', 100);
lb = zeros(size(xhat_init)); 
if any(params_to_fit == 4)
    lb(1) = 0.001*log(2)/8; 
end
[xhat,obj_val] = fmincon(func_handle, xhat_init,[],[],[],[],lb,[],[],opts);

% create params from the initial values and the fit values 
params = patient_info;
params(params_to_fit) = xhat; % update with fit parameters
if any(drugs_to_include==0) % are any drugs not included
    remove_k_idx = find(~drugs_to_include)+4; % drugs are in spaces 5,6, and 7
    params(remove_k_idx) = []; % gets rid of placeholder for missing drugs. continues as previously done now.
end
uhat = params(2);
k0hat = params(4); 

res_std = err_used(xhat,patient_info,tvec,drug_info,dose_times1,dose_times2,dose_times3,drugs_to_include,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,params_to_fit);
epshat = res_std*sqrt(2/(uhat^2*k0hat)); % this is pretty much pointless since the u will generally be around 0
params(3) = NaN; 

params(1) = []; % remove P0 from patient info before passing out, easiest way to reuse params_to_fit
params = [params, res_std]';
err = res_std;

end