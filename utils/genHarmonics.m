function s = genHarmonics(ord_l, angularRes, normScheme, f)
%   m = order
%   n = harmonic [-m, -(m-1), ... , m-1, m]

    assert(angularRes<1000,'Warning, huge angular resolution');

    res = angularRes;
    kr = 2*pi*f/343;

    %theta = 0:theta_tic:(2*pi-theta_tic);
    theta = linspace(-pi, pi, res);

    %phi = (0+phi_tic):phi_tic:(pi);
    phi = linspace(-pi/2, pi/2, res);

    % theta=azi, phi=elev
    s.grid.res      = res;
    s.grid.kr       = kr;
    s.grid.theta    = theta;
    s.grid.phi      = phi;
    [s.grid.theta_gr, s.grid.phi_gr] = meshgrid(theta, phi);

    s.harmonics = grid2poly(s.grid, ord_l, normScheme);

end

