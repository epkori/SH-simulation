%% propagation of patches to the sensor

function [spot_field_patches, spot_intensity_patches, sensor_intensity_ct, spot_field_patches_padded]  = wf_sh_propagation(lambda, f, dx, patch_size, E_propagated_ASM, LENS_COUNT)


    full_field_size = size(E_propagated_ASM, 1);
    
    grid_size = LENS_COUNT;
    
    % Calculate the total size of the lenslet array
    active_area_size = grid_size * patch_size;
    
    % Calculate the starting coordinate to center the active area
    start_coord = round((full_field_size - active_area_size) / 2) + 1;
    
    % Define the loop boundaries
    loop_start = start_coord;
    loop_end = start_coord + (grid_size - 1) * patch_size;
    
    
    spot_field_patches = zeros(patch_size, patch_size, grid_size^2);
    
    pad_factor = 2;
    padded_size = pad_factor * patch_size;
    spot_field_patches_padded = zeros(padded_size, padded_size, grid_size^2);
    
    [x_small, y_small] = meshgrid((-patch_size/2 : patch_size/2 - 1) * dx);
    aperture_radius = (patch_size/2) * dx;
    
    % Square aperture
    aperture = (abs(x_small) <= aperture_radius) & (abs(y_small) <= aperture_radius);
    lens_phase = exp(-1i * (pi / (lambda * f)) * (x_small.^2 + y_small.^2));
    
    count = 1;
    
    output_offset = start_coord - 1;

    full_field_pad = padded_size - patch_size;
    sensor_field_ct = zeros(full_field_size + full_field_pad, full_field_size + full_field_pad);
    
    % Loop through every lenslet (=every wavefront patch)
    for i = loop_start:patch_size:loop_end
        for j = loop_start:patch_size:loop_end
            patch = E_propagated_ASM(i:i+patch_size-1, j:j+patch_size-1);
            patch = patch .* aperture .* lens_phase;
            
            pad_patch = zeros(padded_size);
            center = floor((padded_size - patch_size)/2) + 1;
            pad_patch(center:center+patch_size-1, center:center+patch_size-1) = patch;
    
            propagated_full = fresnel_propagate(pad_patch, lambda, f, dx);
    
            propagated = propagated_full(center:center+patch_size-1, center:center+patch_size-1);
    
            spot_field_patches(:, :, count) = propagated;
            spot_field_patches_padded(:, :, count) = propagated_full;
    
    
            % Add offset to place the patch in the correct location
            y_start = i;
            y_end   = i + padded_size - 1;
            x_start = j;
            x_end   = j + padded_size - 1;
    
            sensor_field_ct(y_start:y_end, x_start:x_end) = ...
                sensor_field_ct(y_start:y_end, x_start:x_end) + ...
                propagated_full;
    
            count = count + 1;
        end
    end
    
    spot_intensity_patches = abs(spot_field_patches).^2;
    sensor_intensity_ct = abs(sensor_field_ct).^2;
    
    % Crop the padding out to get back to the original full resolution
    crop_start = round(full_field_pad/2 + 1);
    crop_end = round(size(sensor_intensity_ct, 1) - full_field_pad/2);
    sensor_intensity_ct = sensor_intensity_ct(crop_start:crop_end, crop_start:crop_end);
    
end

%% Fresnel propagation used to propagate from lenslet to sensor
function U_out = fresnel_propagate(U_in, lambda, z, dx)
    [Ny, Nx] = size(U_in);
    k = 2 * pi / lambda;
    Lx = Nx * dx;
    Ly = Ny * dx;

    [fx, fy] = meshgrid((-Nx/2:Nx/2-1)/Lx, (-Ny/2:Ny/2-1)/Ly);

    H = exp(1i * k * z) * exp(-1i * pi * lambda * z * (fx.^2 + fy.^2));
    H = fftshift(H);

    U_fft = fft2(U_in);
    U_out = ifft2(U_fft .* H);
    
end