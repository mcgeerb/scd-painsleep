function plot_model_r01_talk(tvec,params,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,patient_ID,drugs_to_include,rectangles_or_nah,bad_sleep_or_nah,num_accum,model_version,save_it)
% This function plots the raw data with best fit for the model

%Fsize = 18;
Psize = 5;

% run model using provided parameters (patient_info is P0,u,eps,k0,k_drugs)
[tvec,P,D] = pain_sim_core(tvec,[patient_data(1,2),...
    params(1:length(params)-1)'],...
    drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);

report_pain_real = pain_report_real(2,:);
report_times_real = pain_report_real(1,:);
% place figure in nice spot on screen, and fix ratio
ab=subplot(2,1,2);
% plot model prediction with shaded error regions
h1=plot(tvec,P,'k','LineWidth',2);
ylim([0,100]);
% reorder layers so that error shading doesn't cover up axes
xlabel('Time (hours)');
hold on
% plot real pain report data
plot(report_times_real, report_pain_real, '*m')
if rectangles_or_nah == 1
    for idx = 2:length(report_times_real)
        % 12 hour forward rectangle // shift to 1:(length(report_times_real)-1)
        %rectangle('Position',[report_times_real(idx),min(report_pain_real(idx),report_pain_real(idx+1)),report_times_real(idx+1)-report_times_real(idx),abs(report_pain_real(idx)-report_pain_real(idx+1))])
        %12 hour back rectangle
        rectangle('Position',[report_times_real(idx)-12,report_pain_real(idx)-5,12,10],'FaceColor',[0.4940, 0.1840, 0.5560, 0.3]) %[1, 0, 1, 0.2])
    end
end

if bad_sleep_or_nah == 1
    a = axis;
    for j=1:length(bad_sleep_times)
        plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
    end
end
plot(dose_times1,zeros(size(dose_times1)),'gdiamond','markerfacecolor','g','MarkerSize',8)
grid on

xlim([30,50*ceil(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
hl = legend('Simulation','Pain Response Data','Opioids taken','FontSize',8);
rect = [0.45, 0.46, .025, .025];
set(hl, 'Position',rect)
ylabel('Pain Level');% (0 to 100)');
% number of drug classes taken
num_drugs = length(D(1,:));
% create list of colors to cycle through (for drugs)
all_colors = {'r-.','b--','m:'};
color_ind =  {all_colors{logical(drugs_to_include)}};
ab.Position(2)=.2;
subplot(2,1,1)
hs=scatter(sleep_report_real(1,:), sleep_report_real(2,:),48,'c*');
grid on
hs.Annotation.LegendInformation.IconDisplayStyle = 'off';
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
xlim([30,50*ceil(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
legend('Average Sleep Quality','Location','northeast')
set(gca,'xticklabel',{[]})
ylabel('Reported Sleep quality');
hold off
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
set(gcf, 'PaperPosition', [0 0 0.99*Psize Psize]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [Psize 0.75*Psize]); %Set the paper to have width 5 and height 5.
end
