clear all;
close all;
addpath("functions")
addpath("simulated_sensor_images\")
addpath("height_maps\")


lambda = 538e-9; 
k = 2 * pi / lambda;
grid_size_H = 4000;
dx = 0.012/grid_size_H;  


save_sensor_image = true; 
LENS_PITCH = 150e-6; % okotech: 300, thorlabs: 150um
LENS_COUNT = 75 % 3e-3*2/LENS_PITCH % [i changed it so the pupil radius is 3 mm, i had to manually input the value as it gives some weird float] % 75; % okotech: 31, thorlabs: 75
f = 5.2e-3; % effective focal length okotech: 14.709 mm, thorlabs: 5.2 mm
patch_size = round(LENS_PITCH / dx);

n = 1.6435; 

wf_gen_type = 0;    % 0: "random" wavefront based on zernike polynomial coefficients
                    % 1: wavefront created from DOE height map

[X, Y] = meshgrid((-grid_size_H/2:grid_size_H/2-1)*dx);

if ~wf_gen_type
    % Zernike Generation Parameters
    num_zernikes = 5; 
    max_amplitude = 0.000003; % Max coefficient amplitude
    
    % Coordinate system

    R_pupil = (LENS_COUNT * LENS_PITCH) / 2;
    rho = sqrt(X.^2 + Y.^2) / R_pupil;
    theta = atan2(Y, X);
    mask = rho <= 1;
    
    rng('shuffle'); 
    coeffs = zeros(num_zernikes, 1);
    
    % set random coefficients
    for j = 1:num_zernikes
        [n, m] = noll2nm(j);
        
        % Some decay added to the coefficients depending on index (higher
        % order aberrations are attenuated)
        amplitude_multiplier = max_amplitude / (n + 1); 
        coeffs(j) = (rand(1) - 0.5) * 2 * amplitude_multiplier;
    end
    
    % Set piston and tilt to zero 
    coeffs(1:3) = 0;
    
    % Calculate the wavefront
    wavefront = zeros(size(X));
    for j = 1:num_zernikes
        [n, m] = noll2nm(j);
        Z_j = zernike_polynomial(n, m, rho, theta);
        wavefront = wavefront + coeffs(j) * Z_j;
    end
    
    wavefront(~mask) = 0;
    
    E_in = ones(size(X));
    phase_delay = k * (n - 1) .* wavefront;
    E_out = E_in .* exp(1i * phase_delay);


else % elseif loading a height map
    
    E_in = ones(size(X)); 
    
    % Load height map
    data = load(fullfile('height_maps','height_map_doe.mat'));

    % Delete one row and column from start and end just to make the array
    % 4000x4000
    height_map = data.h;
    height_map(:,end) = [];
    height_map(end, :) = [];
    height_map(:,1) = [];
    height_map(1, :) = [];
    
    % Check variable
    if ~exist('height_map', 'var')
        error('Variable "height_map" not found in the loaded .mat file.');
    end
    
    phase_delay = k * (n - 1) .* height_map;
    E_out = E_in .* exp(1i * phase_delay);

end

%% 

% Propagation of wavefront into a Shack-Hartmann sensor image 
[spot_field_patches, spot_intensity_patches, sensor_intensity_ct, spot_field_patches_full]  = wf_sh_propagation(lambda, f, dx, patch_size, E_out, LENS_COUNT);



%% Save result
if save_sensor_image
    save_sensor_img(sensor_intensity_ct, 12.00, 8.45)
    % original was this save_sensor_img(sensor_intensity_ct, 12.00, 11.264)
end
%% Plot resulting SH-image 

figure;
imagesc(sensor_intensity_ct);
axis image;
colormap gray;
title("Simulated sensor image")
set(gca, 'YTick', [])
set(gca, 'XTick', [])
