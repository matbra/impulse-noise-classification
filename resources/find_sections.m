function st_sections = find_sections(vec_idx)

if isempty(vec_idx)
    st_sections = [];
    return;
end

vec_idx = vec_idx(:); % force input to be a column vector

diff_idx = diff(vec_idx);

section_borders = [find(diff_idx > 1); length(vec_idx)];

cur_idx = 1;
for a = 1 : length(section_borders)
    st_sections(a).idx_start = vec_idx(cur_idx);
    st_sections(a).idx_end = vec_idx(section_borders(a));
    st_sections(a).length = section_borders(a) - cur_idx + 1;
    cur_idx = section_borders(a) + 1;
end




