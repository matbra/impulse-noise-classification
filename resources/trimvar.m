function sigma = trimvar(x, percent)

% throw away [percent] percent of the smallest and largest values and
% calculate variance for the rest
perc_lower = prctile(x, percent);
perc_upper = prctile(x, 100-percent);

x(x < perc_lower | x > perc_upper) = [];

sigma = var(x);