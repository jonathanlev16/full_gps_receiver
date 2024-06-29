function [receiver_position] = get_receiver_position_at_specific_tow(ephemeris_struct_array, pseudoranges, tow)
% this function receives data from at least 4 satellits, ephemeris, and
% pseudo ranges at one point in time - spcefic tow

% Constants
% Speed of light
c = 299792458;
% Earth's rotation rate
omega_e = 7.2921151467e-5; %(rad/sec)

receiver_position = zeros(1,3)-1;
%%
% Arrays to store various outputs of the position estimation algorithm
user_position_arr = [];
HDOP_arr = [];
VDOP_arr = [];
user_clock_bias_arr = [];

% initial position of the user
xu = [0 0 0];
% initial clock bias
b = 1000;

for idx = 1
    % find indicies of rows containing non-zero data. Each row corresponds
    % to a satellite

    % The minimum number of satellites needed is 4, let's go for more than
    % that to be more robust

    % Correct for satellite clock bias and find the best ephemeris data
    % for each satellite.

    % Now lets calculate the satellite positions and construct the G
    % matrix. Then we'll run the least squares optimization to
    % calculate corrected user position and clock bias. We'll iterate
    % until change in user position and clock bias is less than a
    % threhold. In practice, the optimization converges very quickly,
    % usually in 2-3 iterations even when the starting point for the
    % user position and clock bias is far away from the true values.

    dx = 100*ones(1,3); db = 100;
    numSV = 4;

    while(norm(dx) > 0.01 || norm(db) > 1)

        Xs = []; % concatenated satellite positions
        pr = []; % pseudoranges corrected for user clock bias
        
        for i = 1: numSV
            % correct for our estimate of user clock bias. Note that
            % the clock bias is in units of distance

            dsv = estimate_satellite_clock_bias(tow, ephemeris_struct_array{i});
            pr_(i) = pseudoranges(i)+c*dsv;

            cpr = pr_(i) - b;
            pr = [pr; cpr];

            % Signal transmission time
            tau = cpr/c;
            % Get satellite position ,   [xs_ ys_ zs_] = get_satellite_position(ephemeris_struct_array{i}, tow-tau, 1);
            [xs_ ys_ zs_] = get_satellite_position(ephemeris_struct_array{i}, tow, 1);
            % express satellite position in ECEF frame at time t
            theta = omega_e*tau;
            xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
            xs_vec = [xs_ ys_ zs_]';
            Xs = [Xs; xs_vec'];
        end
        % Run least squares to calculate new user position and bias
        [x_, b_, norm_dp, G] = estimate_position(Xs, pr, numSV, xu, b, 3);
        % Change in the position and bias to determine when to quite
        % the iteration

        dx = x_ - xu;
        db = b_ - b;
        xu = x_;
        b = b_;

    end % end of iteration
    % Convert from ECEF to lat/lng
    [lambda, phi, h] = WGStoEllipsoid(xu(1), xu(2), xu(3));
    % Calculate Rotation Matrix to Convert ECEF to local ENU reference
    % frame
    lat = phi*180/pi;
    lon = lambda*180/pi;

    receiver_position(1) = lat;
    receiver_position(2) = lon;
    receiver_position(3) = b;
    

    R1=rot(90+lon, 3);
    R2=rot(90-lat, 1);
    R=R2*R1;
    G_ = [G(:,1:3)*R' G(:,4)];
    H = inv(G_'*G_);
    HDOP = sqrt(H(1,1) + H(2,2));
    VDOP = sqrt(H(3,3));
    % Record various quantities for saving and plotting
    HDOP_arr(end+1,:) = HDOP;
    VDOP_arr(end+1,:) = VDOP;
    user_position_arr(end+1,:) = [lat lon h];
    user_clock_bias_arr(end+1,:) = b;
end

