function content = zero_fill_content(content, max_index)
for i=length(content)+1:max_index
    content{end+1} = '0';
end

