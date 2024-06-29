function res = invs(str)
    res = str;
    res(res==1)=5;
    res(res==0) = 1;
    res(res==5) = 0;
end