clc;
clear;

% Define paths
base_folder = 'F:\';
base_folder1 = 'F:\Annual\';
dem_path = 'F:\XX.tif';
outputFolderPath = 'F:\monthly\';

% Read DEM data
dem = imread(dem_path);
dem_geo = geotiffinfo(dem_path);
dem_data = find(dem ~= -32768); % Mask for valid DEM data

% Now, calculate monthly proportions and apply them to annual data
for year = 1980:2020
    % Load the yearly surface water data from a TIFF file
    year_tiff = sprintf('ChinaWR_TWR_001deg_%d.tif', year); % Adjust filename pattern
    yearly_data = imread(fullfile(base_folder1, year_tiff));
    yearly_data = double(reshape(yearly_data, 27050122, 1)); % Adjust size

    load(fullfile(outputFolderPath, sprintf('monthly_surface_data_%d.mat', year))); % Load monthly data

    % Calculate monthly proportions
    yearly_total = sum(monthly_data, 2); % Annual total for each grid point
    monthly_proportion = monthly_data ./ repmat(yearly_total, 1, 12); % Proportions

    % Save the monthly proportions as a .mat file
    proportion_file = fullfile(outputFolderPath, sprintf('proportion_%d.mat', year));
    save(proportion_file, 'monthly_proportion');

    % Generate new monthly grid data based on proportions and annual data
    new_grid_data = zeros(27050122, 12); % Adjust size
    for month = 1:12
        new_grid_data(:, month) = monthly_proportion(:, month) .* yearly_data;
    end

    % Save the new grid data as TIFF files for each month
    for month = 1:12
        geo_data = reshape(new_grid_data(:, month), 3938, 6869); % Adjust based on grid size
        output_filename = fullfile(outputFolderPath, sprintf('Total_water_%d_%02d.mat', year, month));
        save(output_filename, geo_data);
        output_filename = fullfile(outputFolderPath, sprintf('Total_water_%d_%02d.tif', year, month));
        geotiffwrite(output_filename, geo_data, dem_geo.RefMatrix);
    end
end

