function [sens_out, spec_out,prec_out,npv_out,acc_out,f1_out] = predict_via_hilo(tvec,pain_report_real,sim_pain,thresh_info)
% synopsis: this function measures whether the simulation is in the "pain rectangle"
% it doesn't impose nonegativity at this level. The nonnegativity constraint was added into fmincon

report_times = pain_report_real(1,:);
real_pain = pain_report_real(2,:);

report_pain_sim = interp1(tvec,sim_pain,report_times);

pain_thresh = thresh_info{2};

sim_categs = categorize_pain_hilo(report_pain_sim,0,pain_thresh,100);
real_categs = categorize_pain_hilo(real_pain,0,pain_thresh,100);

TP = sum((sim_categs == 1) & (real_categs == 1));
TN = sum((sim_categs == 0) & (real_categs == 0));
FP = sum((sim_categs == 1) & (real_categs == 0)); 
FN = sum((sim_categs == 0) & (real_categs == 1));

% Sensitivity / Recall / True Positive Rate
sens_out = TP / (TP+FN);
% Specificity / True Negative Rate
spec_out = TN / (TN+FP);
% Precision / Positive Predictive Value
prec_out = TP / (TP+FP);
% Negative Predictive Value
npv_out = TN / (TN+FN);
% Accuracy
acc_out = (TP+TN) / (TP+FN+TN+FP);
% F1 score
f1_out = 2*(prec_out*sens_out) / (prec_out+sens_out);

% references: https://en.wikipedia.org/wiki/Sensitivity_and_specificity
% references: https://en.wikipedia.org/wiki/Confusion_matrix

end