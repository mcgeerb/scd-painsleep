function zone_hit_target = predict_via_rectangle(tvec,pain_report_real,sim_pain)
% synopsis: this function measures whether the simulation is in the "pain rectangle"
% it doesn't impose nonegativity at this level. The nonnegativity constraint was added into fmincon

tot_zone_hits = 0; % # correct
possible_hits = 0;
report_times = pain_report_real(1,:);
real_pain = pain_report_real(2,:);
% loop over reported times
for cur_subinterval_idx = 1:(length(report_times)-1)
    % find which entries in tvec correspond to report times
    if report_times(cur_subinterval_idx) <= tvec(1)
        continue
    end
    if report_times(cur_subinterval_idx)<12
        idx1 = 1; % go to first entry of tvec %find(tvec == tvec(1));
    else
        idx1 = find(tvec == report_times(cur_subinterval_idx)-12);
    end
    idx2 = find(tvec == report_times(cur_subinterval_idx));
    possible_hits = possible_hits + idx2-idx1+1;
    % restrict sim_pain_init to between those indices
    cur_pain_sims = sim_pain(idx1:idx2);
    max_pain_reported = real_pain(cur_subinterval_idx)+5;%, real_pain(cur_subinterval_idx+1));
    min_pain_reported = real_pain(cur_subinterval_idx)-5;%min(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1));
    % compute how close the simulated pain ever got close to the pain rectangle for current 12 hour window
    tot_zone_hits = tot_zone_hits + sum((cur_pain_sims <= max_pain_reported)&(cur_pain_sims >= min_pain_reported));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if any((cur_pain_sims <= max_pain_reported)) % check if the simulated pain is below the top of rectangle
    %         if any((cur_pain_sims >= min_pain_reported)) % check if the simulated pain is above the bottom of rectangle
    %             pain_accur(cur_subinterval_idx) = 1;
    %         %else % the simulated pain is below the bottom of rectangle
    %         %    cur_dists = sqrt((min_pain_reported*ones(size(cur_pain_sims))-cur_pain_sims).^2);
    %         %    pain_accur(cur_subinterval_idx) = min(cur_dists);
    %         end
    %     %else % the simulated pain is above the top of rectangle
    %         %cur_dists = sqrt((cur_pain_sims-max_pain_reported*ones(size(cur_pain_sims))).^2);
    %         %pain_accur(cur_subinterval_idx) = min(cur_dists);
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         if any(abs(cur_pain_sims - max(real_pain(cur_subinterval_idx), real_pain(cur_subinterval_idx+1)))<0.1) % check if the simulated pain ever got close to the maximum pain in that 12 hour window
    %             find (cur_pain_sims - max(real_pain(idx1), real_pain(idx2))<0.1,'first') % where did it happen
    %             pain_accur(cur_subinterval_idx) = 1; % mark that it happened
    %         end
end
if possible_hits == 0
    zone_hit_target = 0;
else
%     fprintf('total hits \n')
%     disp(tot_zone_hits)
%     fprintf('possible hits \n')
%     disp(possible_hits)
    zone_hit_target = tot_zone_hits/possible_hits; % MAKE SURE THIS IS THE RIGHT DENOMINATOR
end
end