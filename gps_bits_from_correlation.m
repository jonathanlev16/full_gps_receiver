function [bit_vector, sub_frames_bits, prn_number_of_first_bit, first_preamble_bit] = gps_bits_from_correlation(correlation_vector)
%gps_bits_from_correlation extracts bits from correlation results.
%gps_bits_from_correlation input is a column vector consisting the (complex)
%correaltion result with each ca_code. output is: (1) a column vector consisting the bits extracted from the correlation results. 
% (b) sub_frames_bits - a matrix where each line is cooresponds to a specific subframe and columns
% are the bit value.

bit_num = 3000-2;

correlation_vector = real(correlation_vector);
indxes = find(diff(sign(correlation_vector))~=0);
% first indx of a bit, taking into account we might started in a double 0 or double 1
prn_number_of_first_bit = mod(indxes(1)+1,20);
reshaped_correlation = reshape((correlation_vector(prn_number_of_first_bit:prn_number_of_first_bit+20*bit_num-1)), 20, []);
mean_reshaped_correlation = mean(reshaped_correlation);

mean_reshaped_correlation((mean_reshaped_correlation)>0) = 1;
mean_reshaped_correlation((mean_reshaped_correlation)<0) = 0;

bit_vector = mean_reshaped_correlation;

%% from bit_vector, extract subframes (and repair inverse bits)

preamble = [1 0 0 0 1 0 1 1];
preamble_not = [0 1 1 1 0 1 0 0];
preamble_loc = strfind(bit_vector, preamble);
preamble_not_loc = strfind(bit_vector, preamble_not);

if(length(preamble_not_loc)>length(preamble_loc))
    preamble_loc = preamble_not_loc;
    bit_vector = invs(bit_vector);
end

    % fix inversed bits - for every 30 bits (word) check the last bit of
    % the previus word, if it was 1, inverse all bits in word but the
    % parity bits, meaning bits 1-24 will be inversed
bit_vector_fixed = bit_vector;
for i=preamble_loc(1)+29:30:length(bit_vector)-30  %may not be genral beacuse we asuemed first find is really the preamble, and we are reversing every 30 words.
     if(bit_vector_fixed(i)==1)
         bit_vector_fixed(i+1:i+24) = invs(bit_vector(i+1:i+24)); 
     end     
end

sub_frames_bits = zeros(1,300);
for i=1:floor(size(bit_vector_fixed,2)/300)-1
    sub_frames_bits(i,:) = bit_vector_fixed(preamble_loc(1)+300*(i-1):preamble_loc(1)+300*i-1);    
end

first_preamble_bit = preamble_loc(1); %may not be general beacuse we asuemed first find is really the preamble

bit_vector = bit_vector_fixed;
end

