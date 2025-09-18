function plot_model_w_rectangles(tvec,params,err,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,fixed_k0,bad_sleep_times,sleep_report_real,beta,sleepqual_tol,patient_ID,drugs_to_include)
% This function plots the raw data with best fit for the model

% run model using provided parameters (patient_info is P0,u,eps,k0,k_drugs)
[tvec,P,D] = pain_sim_core(tvec,[patient_data(1,2),...
    params(1:length(params)-1)'],...
    drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
% [tvec,P,D] = pain_sim_interventions3_sleep(tvec,[patient_data(1,2),...
%     params(1),params(2),fixed_k0,params(3:length(params)-1)'],...
%     drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);
report_pain_real = pain_report_real(2,:);
report_times_real = pain_report_real(1,:);
% place figure in nice spot on screen, and fix ratio
figure('rend','painters','pos',[10 10 800 800])
%subplot(3,1,[1 2]); %original
subplot(3,1,1)
% plot model prediction with shaded error regions
plot(tvec,P,'r','LineWidth',2);
ylim([0,100]);
% reorder layers so that error shading doesn't cover up axes
set(gca,'Layer','top')
hold on
% plot real pain report data
plot(report_times_real, report_pain_real, '*k')
for idx = 2:length(report_times_real)
% 12 hour forward rectangle // shift to 1:(length(report_times_real)-1)
%rectangle('Position',[report_times_real(idx),min(report_pain_real(idx),report_pain_real(idx+1)),report_times_real(idx+1)-report_times_real(idx),abs(report_pain_real(idx)-report_pain_real(idx+1))])
%12 hour back rectangle
rectangle('Position',[report_times_real(idx-1),min(report_pain_real(idx-1),report_pain_real(idx)),report_times_real(idx)-report_times_real(idx-1),abs(report_pain_real(idx-1)-report_pain_real(idx))],'FaceColor',[1, 0, 1, 0.2])
end
a = axis;
for j=1:length(bad_sleep_times)
    plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
end
   % legend
%set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks
ylabel('Pain level (0 to 100)');
% number of drug classes taken
num_drugs = length(D(1,:));
% create list of colors to cycle through (for drugs)
all_colors = {'r-.','b--','m:'};
color_ind =  {all_colors{logical(drugs_to_include)}};
%subplot(3,1,3); original
subplot(3,1,2)
% for each drug class taken, plot drug in bloodstream
for kk = 1:num_drugs
    plot(tvec, D(:,kk),color_ind{kk});
    hold on
end
ylabel('Std. drug doses in bloodstream');
% create list drug names to put on legend
all_drugs = {'LA','SA','NO'};
cur_drugs =  {all_drugs{logical(drugs_to_include)}};
legend(cur_drugs)
subplot(3,1,3)
plot(sleep_report_real(1,:), sleep_report_real(2,:),'c-*','LineWidth',2);
hold on
plot(sleep_report_real(1,:), mean(sleep_report_real(2,:))*ones(size(sleep_report_real(2,:))),'b--','LineWidth',2);
a = axis;
for j=1:length(bad_sleep_times)
    plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
end
hold off
legend('Reported Sleep Quality','Average Sleep Quality')
ylabel('Sleep quality');
xlabel('Time (hours)');
sgtitle(patient_ID);
end