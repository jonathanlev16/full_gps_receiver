function [subframes_struct, ephemeris, first_subframe_with_ID1] = extract_ephemeris_from_subframes(sub_frames_bits)
%EXTRACT_EPHEMERIS_FROM_SUBFRAMES function takes raw bits and ouput all
%subframes data.
for i=1:size(sub_frames_bits,1)
        subframes_struct{i}.ID = bin2dec(num2str(sub_frames_bits(i,50:52)));
        subframes_struct{i}.Bits = sub_frames_bits(i,:);
end
%%

for i=1:size(sub_frames_bits,1)

    subframe = subframes_struct{i}.Bits;

      if(subframes_struct{i}.ID == 1) 
        subframes_struct{i}.af2 = twos_complement(([subframe(241:248)]))*pow2(-55);
        subframes_struct{i}.af1 = twos_complement(([subframe(249:264)]))*pow2(-43);
        subframes_struct{i}.af0 = twos_complement(([subframe(271:292)]))*pow2(-31);
        subframes_struct{i}.tow = bin2dec(strrep(num2str([subframe(31:47)]),' ','  '))*6-6; %check!!!!
        subframes_struct{i}.toc = bin2dec(strrep(num2str([subframe(219:234)]),' ','  '))*16;
      end

      if(subframes_struct{i}.ID == 2)
            subframes_struct{i}.M0 = pi*twos_complement(([subframe(107:114) subframe(121:144)]))*pow2(-31);
            subframes_struct{i}.e = bin2dec(num2str(([subframe(167:174) subframe(181:204)])))*pow2(-33);
            subframes_struct{i}.sqrtA = bin2dec((num2str(([subframe(227:234) subframe(241:264)]))))*pow2(-19);
            subframes_struct{i}.toe = bin2dec(num2str(([subframe(271:286)])))*pow2(4);          
            subframes_struct{i}.cus = (twos_complement(([subframe(211:226)])))*pow2(-29);
            subframes_struct{i}.cuc = (twos_complement([subframe(151:166)]))*pow2(-29);
            subframes_struct{i}.crs = (twos_complement([subframe(69:84)]))*pow2(-5);
            subframes_struct{i}.dn = pi*(twos_complement(([subframe(91:106)])))*pow2(-43);
            subframes_struct{i}.IODE = bin2dec(num2str([subframe(61:68)]));
      end

        if(subframes_struct{i}.ID == 3)
            subframes_struct{i}.cic = twos_complement([subframe(61:76)])*pow2(-29);
            subframes_struct{i}.cis = twos_complement(([subframe(121:136)]))*pow2(-29);
            subframes_struct{i}.Omega0 = pi*twos_complement([subframe(77:84) subframe(91:114)])*pow2(-31);
            subframes_struct{i}.i0 = pi*twos_complement(([ subframe(137:144) subframe(151:174)]))*pow2(-31);
            subframes_struct{i}.crc = twos_complement([subframe(181:196)])*pow2(-5);
            subframes_struct{i}.omega = pi*twos_complement(([subframe(197:204) subframe(211:234)]))*pow2(-31);
            subframes_struct{i}.IDOT = pi*twos_complement([subframe(279:292)])*pow2(-43);
            subframes_struct{i}.OmegaDot = pi*twos_complement(([subframe(241:264)]))*pow2(-43);  
        end
      
end 
%% we want ephemeris to have data from first subframe with ID = 1 and the following 2 subframes.
flag = 0;
for i=1:size(sub_frames_bits,1)
    if(subframes_struct{i}.ID == 1)
        flag = 1;
    end
    if(flag == 0)
        continue;
    end

    if(subframes_struct{i}.ID == 1) 
        ephemeris.af2 = subframes_struct{i}.af2;
        ephemeris.af1 = subframes_struct{i}.af1;
        ephemeris.af0 = subframes_struct{i}.af0;
        ephemeris.tow = subframes_struct{i}.tow;
        ephemeris.toc = subframes_struct{i}.toc;
        first_subframe_with_ID1 = i;
        continue;
    end 

    if(subframes_struct{i}.ID == 2)
        ephemeris.m0 = subframes_struct{i}.M0;
        ephemeris.e = subframes_struct{i}.e;
        ephemeris.sqrtA = subframes_struct{i}.sqrtA;
        ephemeris.toe = subframes_struct{i}.toe;
        ephemeris.cus = subframes_struct{i}.cus;
        ephemeris.cuc = subframes_struct{i}.cuc;
        ephemeris.crs = subframes_struct{i}.crs;
        ephemeris.dn = subframes_struct{i}.dn;
        ephemeris.iod = subframes_struct{i}.IODE; 
        continue;
    end 

    if(subframes_struct{i}.ID == 3)
        ephemeris.cic = subframes_struct{i}.cic;
        ephemeris.cis = subframes_struct{i}.cis;
        ephemeris.omg0 = subframes_struct{i}.Omega0;
        ephemeris.i0 = subframes_struct{i}.i0;
        ephemeris.crc = subframes_struct{i}.crc;
        ephemeris.w = subframes_struct{i}.omega;
        ephemeris.idot = subframes_struct{i}.IDOT;
        ephemeris.odot = subframes_struct{i}.OmegaDot;
        break;
    end 

end 













%  if (subframes{i}.ID==1)
%         flag = 1;
%  end
%     if (flag == 0)
%       continue
%     end





   %subframe1
%         ephemeris.af2 = subframes{i}.af2;
%         ephemeris.af1 = subframes{i}.af1;
%         ephemeris.af0 = subframes{i}.af0;
%         ephemeris.tow = subframes{i}.tow;
%         ephemeris.toc = subframes{i}.toc;

%subframe2
%             ephemeris.m0 = subframes{i}.M0;
%             ephemeris.e = subframes{i}.e;
%             ephemeris.sqrtA = subframes{i}.sqrtA;
%             ephemeris.toe = subframes{i}.toe;
%             ephemeris.cus = subframes{i}.cus;
%             ephemeris.cuc = subframes{i}.cuc;
%             ephemeris.crs = subframes{i}.crs;
%             ephemeris.dn = subframes{i}.dn;
%             ephemeris.iod = subframes{i}.IODE;  

%subframe3
%             ephemeris.cic = subframes{i}.cic;
%             ephemeris.cis = subframes{i}.cis;
%             ephemeris.omg0 = subframes{i}.Omega0;
%             ephemeris.i0 = subframes{i}.i0;
%             ephemeris.crc = subframes{i}.crc;
%             ephemeris.w = subframes{i}.omega;
%             ephemeris.idot = subframes{i}.IDOT;
%             ephemeris.odot = subframes{i}.OmegaDot;


%     flag = 0;
%  if (subframes{i}.ID==1)
%         flag = 1;
%     end
%     if (flag == 0)
%       continue
%     end
  
