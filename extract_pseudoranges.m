function [pseudoranges_per_bit] = extract_pseudoranges(first_preamble_bit,prn_number_of_first_bit, track_indexs, number_of_subframes, Fs,c)
%this function outputs the index location of every bit starting from the
%first preamble of first subframe. meaning first index of first bit in first subframe in signal.


correlation_number_of_first_preamble = prn_number_of_first_bit + (first_preamble_bit-1)*(20);
bit_index_from_first_subframe = track_indexs(correlation_number_of_first_preamble:20:(correlation_number_of_first_preamble+number_of_subframes*300*20)-20);
pseudoranges_per_bit = bit_index_from_first_subframe*c*(1/Fs);




%this outputs the pseduranges of every bit starting from first bit of first subframe