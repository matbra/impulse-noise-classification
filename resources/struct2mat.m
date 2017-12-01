function [mat_output, idx_valid] = struct2mat(st_input, b_skip_empty, c_fieldnames)

if nargin < 3
    c_fieldnames = fieldnames(st_input);
end
   
N_fieldnames = length(c_fieldnames);
N_datasets = length(st_input);

mat_output = zeros(N_fieldnames, N_datasets);

b_valid = true(N_datasets, 1);
idx_valid = (1:N_datasets)';

for a = 1 : N_fieldnames
    for b = 1 : N_datasets
        cur_value = st_input(b).(c_fieldnames{a});
        
        if isempty(cur_value)
            cur_value = -1;
            warning('a feature was empty.');
            b_valid(b) = false;
        end
        mat_output(a, b) = cur_value;
    end
end

if b_skip_empty
    mat_output = mat_output(:, b_valid);
    idx_valid = find(b_valid);
end

