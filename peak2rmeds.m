function p2m = peak2rmeds(x)

rmedians_x = sqrt(median(x.^2));

peak_x = max(abs(x));

p2m = peak_x ./ rmedians_x;