function res = twos_complement(binary_string)
    if(binary_string(1)==0)
        res = bin2dec(num2str(binary_string));
    else
        res = num2str(~(binary_string));
        tmp = (bin2dec(res)+bin2dec('001'));
        res = -tmp;
    end
end