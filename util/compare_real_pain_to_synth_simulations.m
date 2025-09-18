function compare_real_pain_to_synth_simulations(tvec,params,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,patient_ID,drugs_to_include,rectangles_or_nah,bad_sleep_or_nah,num_accum,model_version,save_it)
% This function plots the raw data with best fit for the model

Fsize = 18;
Psize = 5;

% tempa = 0; tempb= 800;
% tvec = tvec(tvec>=tempa&tvec<=tempb);  %  focus in on the window for the talk plots
% sleep_report_real(:,(sleep_report_real(1,:)<tempa|sleep_report_real(1,:)>tempb)) = [];
% pain_report_real(:,(pain_report_real(1,:)<tempa|pain_report_real(1,:)>tempb)) = [];
% bad_sleep_times((bad_sleep_times<tempa|bad_sleep_times>tempb))=[];

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
%figure('rend','painters','pos',[10 10 800 800])
%subplot(3,1,[1 2]); %original
subplot(1,2,1)
% plot model prediction with shaded error regions
plot(tvec,P,'k','LineWidth',2);
ylim([0,100]);
% reorder layers so that error shading doesn't cover up axes
set(gca,'Layer','top', 'FontSize', Fsize-2)
hold on
% plot real pain report data
plot(report_times_real, report_pain_real, '*m')
if rectangles_or_nah == 1
    for idx = 2:length(report_times_real)
        % 12 hour forward rectangle // shift to 1:(length(report_times_real)-1)
        %rectangle('Position',[report_times_real(idx),min(report_pain_real(idx),report_pain_real(idx+1)),report_times_real(idx+1)-report_times_real(idx),abs(report_pain_real(idx)-report_pain_real(idx+1))])
        %12 hour back rectangle
        rectangle('Position',[report_times_real(idx-1),min(report_pain_real(idx-1),report_pain_real(idx)),report_times_real(idx)-report_times_real(idx-1),abs(report_pain_real(idx-1)-report_pain_real(idx))],'FaceColor',[1, 0, 1, 0.2])
    end
end
if bad_sleep_or_nah == 1
a = axis;
 for j=1:length(bad_sleep_times)
     plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
 end
end
legend('Simulation','Data')
%set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks
ylabel('Pain level (0 to 100)');
% number of drug classes taken
num_drugs = length(D(1,:));
% create list of colors to cycle through (for drugs)
all_colors = {'r-.','b--','m:'};
color_ind =  {all_colors{logical(drugs_to_include)}};
%subplot(3,1,3); original
% subplot(3,1,2)
% % for each drug class taken, plot drug in bloodstream
% for kk = 1:num_drugs
%     plot(tvec, D(:,kk),color_ind{kk});
%     hold on
% end
% ylabel('Std. drug doses in bloodstream');
% % create list drug names to put on legend
% all_drugs = {'LA','SA','NO'};
% cur_drugs =  {all_drugs{logical(drugs_to_include)}};
% legend(cur_drugs)
subplot(1,2,2)
plot(sleep_report_real(1,:), sleep_report_real(2,:),'c-*','LineWidth',2);
hold on
if (size(sleep_report_real,1)==3)
    sq_mu = mean(sleep_report_real(3,:));
else
    sq_mu = mean(sleep_report_real(2,:));
end
plot(sleep_report_real(1,:), sq_mu*ones(size(sleep_report_real(2,:))),'b--','LineWidth',2);
if bad_sleep_or_nah == 1
a = axis;
 for j=1:length(bad_sleep_times)
     plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
 end
end
hold off
legend('Reported Sleep Quality','Average Sleep Quality')
ylabel('Sleep quality');
xlabel('Time (hours)');
sgtitle(patient_ID);
% determine the filename
if bad_sleep_or_nah == 1
    if rectangles_or_nah == 1
        filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_w_rect_w_bs'];
    else
        filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_no_rect_w_bs'];
    end
else
    if rectangles_or_nah == 1
        filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_w_rect_no_bs'];
    else
        filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_no_rect_no_bs'];
    end
end
% dimensions and  commands from old saplots code
set(gca, 'FontSize', Fsize-2);
set(gcf, 'PaperPosition', [0 0 2*Psize Psize]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [2*Psize Psize]); %Set the paper to have width 5 and height 5.
if save_it == 1
    saveas(gcf, ['../plotting/',filename], 'pdf') %Save figure
end
end
