function sp = sparseness(mat_input, dim)
% after
% hoyer, dayan 2004:
% "non-negative matrix factorization with sparseness..."

if nargin == 1
    dim = find(size(mat_input)~=1,1);
end

size_input = size(mat_input);

if dim == 1
    n = size_input(1);
elseif dim == 2
    n = size_input(2);
end

sp = (sqrt(n) - sum(abs(mat_input), dim) ./ sqrt(sum(mat_input.^2, dim))) / (sqrt(n) - 1);