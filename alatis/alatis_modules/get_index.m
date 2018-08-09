function new_index=get_index(Map, index)
[~, new_index] = min(abs(Map-index));

