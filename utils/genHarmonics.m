function s = genHarmonics(ord, angularRes, normScheme, f)
%
%   Generates spherical harmonics and outputs into a struct. This function 
%   generates the spherical harmonic weights for a queried grid of 
%   spherical (azimuth and elevation) angles for sake of visualization and
%   is not required for ambisonic processing.
%
%   ARGUMENTS
%   ord             [int] Ambisonic order (i.e. spherical harmonics are
%                   generated for {0, 1, ..., ord-1, ord})
%   
%   angularRes      [int] Angular resolution: determines the resolution of
%                   the visualization
%
%   normScheme      [str] {'SN3D','N3D'} Applies harmonic weights for
%                   semi-normalized or fully-normalized conventions,
%                   respectively
%
%   f               [float] Frequency used for evaluating Bessel function 
%                   (todo: elaborate)


%   Reference:
%   m = order
%   n = harmonic [-m, -(m-1), ... , m-1, m]

    assert(angularRes<1000,'Angular resolution too high');

    res = angularRes;
    kr = 2*pi*f/343;
    
    theta = linspace(-pi, pi, res); % azimuth
    phi = linspace(-pi/2, pi/2, res); % elevation

    % Generate grid of spherical angles
    s.grid.res      = res;
    s.grid.kr       = kr;
    s.grid.theta    = theta;
    s.grid.phi      = phi;
    [s.grid.theta_gr, s.grid.phi_gr] = meshgrid(theta, phi);

    % Populate grid with harmonics via spherical (polynomial) expansion
    s.harmonics = grid2poly(s.grid, ord, normScheme);

    s.signal{1} = [];
    
end

