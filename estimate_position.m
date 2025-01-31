	function [x, b, norm_dp, G] = estimate_position(xs, pr, numSat, x0, b0, dim)
	% estimate_position: estimate the user's position and user clock bias
	% Usage: [x, b, norm_dp, G] = estimate_position(xs, pr, numSat, x0, b0, dim)
	% Input Args: xs: satellite position matrix
	%             pr: corrected pseudo ranges (adjusted for known value of the
	%             satellite clock bias)
	%             numSat: number of satellites
	%             x0: starting estimate of the user position
	%             b0: starting point for the user clock bias
	%             dim: dimensions of the satellite vector. 3 for 3D, 2 for 2D
	% Notes: b and b0 are usually 0 as the current estimate of the clock bias
	% has already been applied to the input pseudo ranges.
	% Output Args: x: optimized user position
	%              b: optimized user clock bias
	%              norm_dp: normalized pseudo-range difference
	%              G: user satellite geometry matrix, useful for computing DOPs

	dx = 100*ones(1, dim);
	db = 0;
	norm_dp = 100;
	numIter = 0;
	b = b0;
	%while (norm_dp > 1e-4)
	while norm(dx) > 1e-3
		norms = sqrt(sum((xs-repmat(x0, length(xs), 1)).^2,2));
		% delta pseudo range:
		dp = pr - norms + b - b0;
		G = [-(xs-repmat(x0, length(xs), 1))./repmat(norms, 1, 3) ones(numSat,1)];
		sol = inv(G'*G)*G'*dp;
		dx = sol(1:dim)';
		db = sol(dim+1);
		norm_dp = norm(dp);
		numIter = numIter + 1;
		x0 = x0 + dx;
		b0 = b0 + db;
	end
	x = x0;
	b = b0;
	end