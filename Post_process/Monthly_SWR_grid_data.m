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

% Train the regression model (assuming the training data has no NaNs)
data1 = readmatrix('XX.xlsx');
data1 = data1(~any(isnan(data1), 2), :); % Exclude NaN rows
XTrain_c = data1(:, 1:end-1);
YTrain_c = data1(:, end);

leaf = 5;
ntrees = 500;
fboot = 1;
surrogate = 'off';
kfold = 5;

mdl_c = TreeBagger(ntrees, XTrain_c, YTrain_c, ...
    'Method', 'regression', 'oobvarimp', 'on', ...
    'surrogate', surrogate, 'minleaf', leaf, 'FBoot', fboot);

% Loop through the years 1980 to 2020
for year = 1980:2020
    monthly_data = zeros(9622717, 12); % Adjust size based on your grid

    for month = 1:12
        all_images = [];

        % Load TIFF files for each month
        subfolders = dir(fullfile(base_folder, '*'));
        for folder_index = 3:length(subfolders)
            if subfolders(folder_index).isdir
                current_folder = fullfile(base_folder, subfolders(folder_index).name);
                tiff_files = dir(fullfile(current_folder, '*.tif'));

                % Filter files by year and month
                year_str = num2str(year);
                month_str = num2str(month);
                for file_index = 1:length(tiff_files)
                    if contains(tiff_files(file_index).name, year_str) && contains(tiff_files(file_index).name, month_str)
                        file_name = tiff_files(file_index).name;
                        image = imread(fullfile(current_folder, file_name));
                        image_data = reshape(image, 27050122, 1); % Adjust based on grid size
                        matches_images = double(image_data(dem_data));
                        break;
                    end
                end
                all_images = [all_images, matches_images];
            end
        end

        % Simulate monthly surface water data using the trained model
        XTest = all_images;
        y_vali = predict(mdl_c, XTest);
        monthly_data(:, month) = y_vali;
    end

    % Save the monthly data as .mat file
    output_mat_file = fullfile(outputFolderPath, sprintf('monthly_surface_data_%d.mat', year));
    save(output_mat_file, 'monthly_data');
end

% Now, calculate monthly proportions and apply them to annual data
for year = 2000:2020
    % Load the yearly surface water data from a TIFF file
    year_tiff = sprintf('ChinaWR_SWR_001deg_%d.tif', year); % Adjust filename pattern
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
        output_filename = fullfile(outputFolderPath, sprintf('surface_water_%d_%02d.mat', year, month));
        save(output_filename, geo_data);
        output_filename = fullfile(outputFolderPath, sprintf('new_surface_water_%d_%02d.tif', year, month));
        geotiffwrite(output_filename, geo_data, dem_geo.RefMatrix);
    end
end

