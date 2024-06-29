function [correlation, track_indexs] = GPS_tracking(filename,Fs, IF,f_doppler, first_corr_indx, satellite_num, num_bits_to_read)
%GPS_tracking - find all correlation values for a visible satellite and in addition document the first index of
% each correlation location.
%inputs are: (1) filename - the raw signal file name, (2) Fs - sampling
%frequency, (3) IF - intermidiate frequency, (4) f_doppler - the initial doppler frequency shift, 
% (5) first_corr_indx - the first index of the first ca-code found in
%signal, (6) satellite_num - the visible satellite number and (7)
%num_bits_to_read - the number of bits wanted to be extracted (up to plus or minus 1 bits).
%outputs are 2 vectors: (1) correlation - a column vector consisting the chronological
%correlation values with each ca_code in signal and (2) track_indexs - 
%a row vector consisting the first index of each ca_code in signal

%% open and read file
fID = fopen(filename,'r');
samples = fread(fID, first_corr_indx-2, '*ubit1');

%% generate ca code and start samples from (first_corr_indx -1).
prn_chip_freq = 1.023e06;
prn_chip_len = 1023;

ca_codes = cacode(1:31,Fs/prn_chip_freq);
ca_code = ca_codes(satellite_num, :);
ca_code = 2*(ca_code-0.5);
correlation_values = zeros(1,4);
theta0 = 0;
track_indexs = zeros(1,num_bits_to_read*20); 

samples = fread(fID, 1 + (Fs/prn_chip_freq)*prn_chip_len + 1, '*ubit1'); %pointer is at first_corr_indx - 1. hence reading +2 will result +1 before and +1 after ca_code length

%% ca_codes are sent consecutively, hence we jump precise length (up to small fixes) and calculate correlation value.

for i = 1:num_bits_to_read*20
    samples = 2*(double(samples)-0.5);
    t = 0:1/Fs:(size(samples,1).*1/Fs);
    t = t(1:size(samples,1));

    exp_baseband_fix = exp(1j*(2*pi*(IF + f_doppler).*t+theta0));

    samps_baseband = exp_baseband_fix'.*samples;
   
    correlation_values(i,1) = (samps_baseband(1:end-2).'*ca_code'); %check correlation with 1 move to left (w.r to precise jump)
    correlation_values(i,2) = (samps_baseband(2:end-1).'*ca_code'); %check correlation with precise jump
    correlation_values(i,3) = (samps_baseband(3:end).'*ca_code'); %check correlation with 1 move to right (w.r to precise jump)
    
   
    [~, max_indx] = max(abs(correlation_values(i,:)));
    correlation_values(i,4) = correlation_values(i,max_indx); 
  
    if (i==1)
        track_indexs(i) = first_corr_indx;
    end 
    
    if(max_indx == 2) %correaltion was maximal exactly (Fs/prn_chip_freq)*prn_chip_len bits after prev maximam
          %add precise jump to tracker
          if (i>1)
            track_indexs(i) =  track_indexs(i-1)+(Fs/prn_chip_freq)*prn_chip_len;
          end
          samples = [samples(end-1:end);fread(fID, (Fs/prn_chip_freq)*prn_chip_len, '*ubit1')];

    elseif(max_indx == 1) %correaltion was maximal exactly (Fs/prn_chip_freq)*prn_chip_len -1 bits after prev maximam
        %subtract 1 to tracker (w.r to precise jump)
        if (i>1)
         track_indexs(i) =  track_indexs(i-1)+(Fs/prn_chip_freq)*prn_chip_len-1;
        end
        samples = [samples(end-2:end);fread(fID, (Fs/prn_chip_freq)*prn_chip_len-1, '*ubit1')];
        

    elseif(max_indx == 3) %correaltion was maximal exactly (Fs/prn_chip_freq)*prn_chip_len +1 bits after prev 
         %add 1 to tracker (w.r to precise jump)
         if (i>1)
            track_indexs(i) =  track_indexs(i-1)+(Fs/prn_chip_freq)*prn_chip_len+1;
         end
         samples = [samples(end:end);fread(fID, (Fs/prn_chip_freq)*prn_chip_len+1, '*ubit1')];
    end

    % repair phases 
      theta0 = angle(exp_baseband_fix(end + max_indx - 3));

    if(i>1)
        theta_prev = (angle(correlation_values(i-1,4)));
        theta_new = (angle(correlation_values(i,4)));
        dtheta = wrapToPi(2*(theta_new-theta_prev))/2;
        theta_new = wrapToPi(2*(theta_new))/2;
        a = 40;
        b = 10;
        f_doppler = f_doppler+a*dtheta+b*theta_new;

    end

end

correlation = correlation_values(:,4); 
track_indexs =  track_indexs.';