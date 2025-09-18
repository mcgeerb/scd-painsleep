function plot_model_paper_fit_july25(tvec,params,patient_data,drug_info,dose_times1,dose_times2,dose_times3,pain_report_real,bad_sleep_times,sleep_report_real,sleepqual_tol,patient_ID,drugs_to_include,rectangles_or_nah,bad_sleep_or_nah,num_accum,model_version,save_it,pain_thresh)
% This function plots the raw data with best fit for the model

%Fsize = 18;
Psize = 8;


% run model using provided parameters (patient_info is P0,u,eps,k0,k_drugs)
[tvec,P,D] = pain_sim_core(tvec,[patient_data(1,2),...
    params(1:length(params)-1)'],...
    drug_info,dose_times1,dose_times2,dose_times3,bad_sleep_times,sleep_report_real,sleepqual_tol);

%%

report_pain_real = pain_report_real(2,:);
report_times_real = pain_report_real(1,:);

% begin plotting

subplot(2,1,1)
hs=scatter(sleep_report_real(1,:), sleep_report_real(2,:),48,'c*','LineWidth',2);
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
legend('Average Sleep Quality','FontSize',8,'Position',[0.479086892488954 0.861904761904762 0.214285714285714 0.0333333333333333]);
xlim([30,50*round(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
set(gca,'xticklabel',{[]})
ylabel('Reported Sleep quality');
hold off

%%
subplot(2,1,2);
hold on
plot(report_times_real, report_pain_real, '*m','MarkerSize',8)
if rectangles_or_nah == 1
    for idx = 2:length(report_times_real)
       %12 hour back rectangle
        rectangle('Position',[report_times_real(idx)-12,report_pain_real(idx)-5,12,10],'FaceColor',[0.4940, 0.1840, 0.5560, 0.3]) %[1, 0, 1, 0.2])
    end
end
h1=plot(tvec,P,'k','LineWidth',2);
plot(dose_times1,zeros(size(dose_times1)),'gdiamond','markerfacecolor','g','MarkerSize',8)
xlim([30,50*round(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
ylim([0,100]);
xlabel('Time (hours)');
ylabel('Pain Level');% (0 to 100)');
legend('Simulation','Pain Response Data','Medications taken','FontSize',8,'Location','best');
%title('Zone Hits')
hold off
%bc.Position(2)=.2;

%%

% % place figure in nice spot on screen, and fix ratio
% %figure('rend','painters','pos',[10 10 800 800])
% ab=subplot(2,2,4);
% % plot model prediction with shaded error regions
% h1=plot(tvec,P,'k','LineWidth',2);
% %h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
% ylim([0,100]);
% % reorder layers so that error shading doesn't cover up axes
% %set(gca,'Layer','top', 'FontSize', Fsize-2)
% xlabel('Time (hours)');
% hold on
% % plot real pain report data
% plot(report_times_real, report_pain_real, '*m')
% % plot binary classification band
% if rectangles_or_nah == 1
%          rectangle('Position',[tvec(1),pain_thresh,tvec(end)-tvec(1),100-pain_thresh],'FaceColor',[0.4940, 0.1840, 0.5560, 0.3]) %[1, 0, 1, 0.2])
% end
% %h2.Annotation.LegendInformation.IconDisplayStyle = 'off';
% if bad_sleep_or_nah == 1
%     a = axis;
%     for j=1:length(bad_sleep_times)
%         plot([bad_sleep_times(j); bad_sleep_times(j)], [a(3); a(4)], 'b--', 'LineWidth', 1);
%     end
% end
% plot(dose_times1,zeros(size(dose_times1)),'gdiamond','markerfacecolor','g','MarkerSize',8)
% %xlim([30,pain_report_real(1,end)]) % round to the nearest multiple of 50
% xlim([30,50*round(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
%xlim([30,50*ceil(pain_report_real(1,end)/50)]) % round to the nearest multiple of 50
%hl = legend('Simulation','Pain Response Data','Medications taken','FontSize',8,'Location','northoutside');
%set(gca,'yticklabel',{[]})
% %title('Binary Classification')
% hold off
% ab.Position(2)=.2;

%legend('Reported Sleep Quality','Average Sleep Quality')
sgtitle(patient_ID);
% % determine the filename
% if bad_sleep_or_nah == 1
%     if rectangles_or_nah == 1
%         filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_w_rect_w_bs'];
%     else
%         filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_no_rect_w_bs'];
%     end
% else
%     if rectangles_or_nah == 1
%         filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_w_rect_no_bs'];
%     else
%         filename = [patient_ID,'_',model_version,'_accum',num2str(num_accum),'_no_rect_no_bs'];
%     end
% end


% dimensions and  commands from old saplots code
%set(gca, 'FontSize', Fsize-2);
set(gcf, 'PaperPosition', [0 0 0.99*Psize Psize]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [1.5*Psize Psize]); %Set the paper to have width 5 and height 5.

end
