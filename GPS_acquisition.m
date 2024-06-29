function satellites_found_in_samples = GPS_acquisition(filename, Fs, IF, length_of_signal_for_acquisition)
% GPS acquisition - find visible satellites and output initial information about them.
%inputs are: (1) filename - the raw signal file name, (2) Fs - sampling
%frequency (3) IF- intermidiate frequency and (4)
%length_of_signal_for_acquisition - sample length wanted for acquisition.
%output is a matrix where each row is a visible satellite and it has 4 columns:
% column 1 - satellite id, column 2 - first correlation index, column 3 -
% max correlation value, column 4 - doppler frequency.

%% open and read file
 fileID = fopen(filename,'r'); 
 samples = fread(fileID, '*ubit1');
 fclose(fileID);
%% crop samples and create time axis

limit = length_of_signal_for_acquisition;
samples_limited = 2*(double(samples(1:limit))-0.5); %move samples from [0,1] to [-1,1]
t = 0:1/Fs:(size(samples_limited,1).*1/Fs);
t = t(1:size(samples_limited,1));

%% bring samples from IF to baseband and generate ca codes

exp_IF_freq = exp(1i*(2*pi*IF)*t);
samples_in_baseband = (exp_IF_freq)'.*(samples_limited);

prn_chip_freq = 1.023e06;
ca_codes = cacode(1:31,Fs/prn_chip_freq);
%% search for visible satellites in signal. signal may not be in baseband (doppler shift) hence the doppler loop.

correlation_data = -1.*ones(size(ca_codes,1),3); %max_lag, correlation value, doppler frequency

for current_satellite = 1:size(ca_codes,1)
    current_ca_code = 2*(ca_codes(current_satellite,:)-0.5); %extract current ca_code and move from [0,1] to [-1,1]

    for doppler_freq_fix = -10e03:10:10e03 
        doppler_exp_fix = exp(1i*2*pi*doppler_freq_fix.*t); 
        samples_in_baseband_fixed = doppler_exp_fix'.*samples_in_baseband; 
        [correlation_result] = xcorr(samples_in_baseband_fixed, current_ca_code); 
        correlation_result = correlation_result(length(samples_in_baseband_fixed): length(samples_in_baseband_fixed)+length(current_ca_code) - 1); %bring index 1 in correaltion result so that index 1 is first full correlation
        [correlation_max_value, max_corr_index] = max(abs(correlation_result)); 
        if(correlation_max_value >= (correlation_data(current_satellite, 2)))
            correlation_data(current_satellite,:) = [(max_corr_index), (correlation_max_value), (doppler_freq_fix)]; 
        end
    end
end

%% choose visible satellites (correlation above thershold), and output their data.
correlation_threshold = 450;
IDs_of_satellites_found = find(correlation_data(:,2)>correlation_threshold);
satellites_found_in_samples = [IDs_of_satellites_found correlation_data(IDs_of_satellites_found,:)]; %satellite_number ,max_corr_index, correlation value, doppler frequency
