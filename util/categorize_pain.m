function [out,low_idx,med_idx,hi_idx] = categorize_pain(pain_vec,min_pain,low_thresh,med_thresh,max_pain)
% synopsis: categoriztion of pain as high/med/low. 
% Uses [0,35) [35,65) [65,100] by default, can specify different cutoffs if desired

% initialize output vector
out = NaN*ones(size(pain_vec));

% setup endpoints for hi/med/low pain bins
if isempty(min_pain)
    min_pain = 0;
end

if isempty(low_thresh)
    low_thresh = 35;
end

if isempty(med_thresh)
    med_thresh = 65;
end

if isempty(max_pain)
    max_pain = 100;
end

% do the categorization
low_idx = (pain_vec >=min_pain) && (pain_vec < low_thresh); % find all the positions of pain values between 0 and 36
out(low_idx) = 0; % categorizes the positions as low pain 

med_idx = (pain_vec >= low_thresh) && (pain_vec < med_thresh); % find all the positions of pain values between 0 and 36
out(med_idx) = 1; % categorizes the positions as medium pain

hi_idx = (pain_vec >= med_thresh) && (pain_vec <= max_pain); % find all the positions of pain values between 0 and 36
out(hi_idx) = 2; % categorizes the positions as high pain

if any(isnan(out))
    warning('Ayo something is up with the pain vector')
end

end