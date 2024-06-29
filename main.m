visible_sats = GPS_acquisition("gps.samples.1bit.I.fs5456.if4092.bin", 5.456e06, 4.092e06, 11e03);

%%
c = 299792458;
Fs = 5.456e06;
IF =  4.092e06;
ephemeris_struct_array = {};
pseudoranges = [];
for satellite_num = 1:size(visible_sats,1)
    [correlation, track_indexs] = GPS_tracking("gps.samples.1bit.I.fs5456.if4092.bin", Fs, IF,visible_sats(satellite_num,4), visible_sats(satellite_num,2), visible_sats(satellite_num,1),3000);
    
    [~, sub_frames_bits, prn_number_of_first_bit, first_preamble_bit] = gps_bits_from_correlation(correlation);
    
    %in our code all pseudo ranges are relative to the first bit of the
    %first full subframe of type 1 and thats why we need first_subframe_with_ID1
    [subframes_struct, ephemeris, first_subframe_with_ID1] = extract_ephemeris_from_subframes(sub_frames_bits);

     
    % this part caclulates the pseudo ranges for all of the bits starting
    % from the first subframe (not nececerily ID1), we later use only the
    % pseudo range calculated at the bit matching the first bit of the
    % first ID1 subframe

    [pseudo_ranges_per_bit] = extract_pseudoranges(first_preamble_bit,prn_number_of_first_bit, track_indexs, size(subframes_struct,2), Fs, c);


   savepseudo(satellite_num,:)= pseudo_ranges_per_bit;
    
    ephemeris_struct_array{satellite_num} = ephemeris;
    pseudoranges(1,satellite_num) = pseudo_ranges_per_bit((first_subframe_with_ID1-1)*300+1);
end
%%
% ephemeris_struct_array_shortend = ephemeris_struct_array(2:5);
% pseudoranges_shortend = pseudoranges(2:5);
% ephemeris_struct_array_ = ephemeris_struct_array(3:6);
% pseudoranges_= pseudoranges(3:6);

reciever_position = get_receiver_position_at_specific_tow(ephemeris_struct_array', pseudoranges, ephemeris_struct_array{1}.tow);
reciever_position(1) 
reciever_position(2)
reciever_position(3)
