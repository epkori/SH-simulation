
% Save simulated sensor image (cropped and downscaled to match the lab
% sensor specs

function save_sensor_img(sensor_intensity, phys_size_mm, crop_size_mm)

[height_px, width_px, ~] = size(sensor_intensity);
pixel_size_mm = phys_size_mm / width_px;
crop_size_px = round(crop_size_mm / pixel_size_mm);
start_x = round((width_px - crop_size_px) / 2);
start_y = round((height_px - crop_size_px) / 2);
sensor_cropped = sensor_intensity(start_y+1:start_y+crop_size_px, start_x+1:start_x+crop_size_px, :);
sensor_downscaled = imresize(sensor_cropped, [1536 1536], "bicubic"); % [i changed it from 2048x2048 to 1536x1536]
I2 = 255*(sensor_downscaled - min(sensor_downscaled(:))) ./ (max(sensor_downscaled(:)) - min(sensor_downscaled(:))); %scale values between 0 and 255
I2 = cast(I2,'uint8');

date_str = datestr(datetime("now"), 'yyyymmdd_HHMMSS');
filename = strcat('sensor_image_', date_str, '.png');
fname = fullfile("simulated_sensor_images", filename);
imwrite(I2, fname);


end