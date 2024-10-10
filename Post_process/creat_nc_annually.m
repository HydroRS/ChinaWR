clc;
clear;

% Set data paths
DemPath = fullfile('');
Outpath = fullfile('');

startYear = 1980;
endYear = 2020;
This_variable = 'ChinaWR_TWR_010deg';
dataPath = fullfile(Outpath, [This_variable, 'tif']);

% Read DEM data
[DemTIF_data, geographic_R] = readgeoraster(fullfile(DemPath, 'XX.tif'));
DemTIF_data = double(DemTIF_data); % Convert to double for numeric operations
TIF_info = geotiffinfo(fullfile(DemPath, 'XX.tif'));

% Find valid grid points (excluding -32768 as invalid data)
[m, n] = find(DemTIF_data ~= -32768);
Grid_linearIdx = sub2ind(size(DemTIF_data), m, n);

% Get dimensions of DEM
[TIF_n, TIF_m] = size(DemTIF_data);

% Convert pixel to lat/lon coordinates
[TIF_lat, ~] = pix2latlon(TIF_info.RefMatrix, (1:TIF_n)', ones(TIF_n, 1));
[~, TIF_lon] = pix2latlon(TIF_info.RefMatrix, ones(TIF_m, 1), (1:TIF_m)');

% Flip latitude if necessary (NetCDF might need flipped latitudes)
TIF_lat_flipud = flipud(TIF_lat);

for Year = startYear:endYear
    year_samplength = num2str(Year, '%04d');
    
    % Create output folder if it doesn't exist
    Final_YearlyOutPath = fullfile(Outpath, This_variable);
    if ~exist(Final_YearlyOutPath, 'dir')
        mkdir(Final_YearlyOutPath);
    end
    
    % Initialize yearly data (assuming you have data for each year to store)
    Yearly_Col = single(zeros(length(Grid_linearIdx), 1)); % Pre-allocate the array for grid points
    
    % Prepare the NetCDF file name
    Out_Yearly_Filename = [This_variable, '_', year_samplength, '.nc'];
    out_YearFile = fullfile(Final_YearlyOutPath, Out_Yearly_Filename);
    
    % Create yearly data array (nan initially)
    Yearly2nc = single(nan(TIF_n, TIF_m)); 
    Yearly2nc(Grid_linearIdx) = nansum(Yearly_Col, 2); % Replace NaN values for valid grids
    Yearly2nc_rot90 = rot90(Yearly2nc, -1); % Rotate the data if necessary for orientation
    
    % Create NetCDF file
    ncid_yearly = netcdf.create(out_YearFile, 'NETCDF4'); % Use NETCDF4 format
    
    % Define dimensions for longitude and latitude
    lonDimId = netcdf.defDim(ncid_yearly, 'lon', length(TIF_lon));
    latDimId = netcdf.defDim(ncid_yearly, 'lat', length(TIF_lat));
    
    % Define variables for longitude, latitude, and TWR (Total Water Resources)
    lonVarid = netcdf.defVar(ncid_yearly, 'lon', 'NC_FLOAT', lonDimId);
    latVarid = netcdf.defVar(ncid_yearly, 'lat', 'NC_FLOAT', latDimId);
    precVarid = netcdf.defVar(ncid_yearly, 'Total water resource (TWR)', 'NC_FLOAT', [lonDimId, latDimId]);
    
    % Enable compression for the TWR variable
    netcdf.defVarDeflate(ncid_yearly, precVarid, true, true, 5);
    
    % End definition mode (start writing data)
    netcdf.endDef(ncid_yearly);
    
    % Write data to the NetCDF file
    netcdf.putVar(ncid_yearly, lonVarid, TIF_lon);
    netcdf.putVar(ncid_yearly, latVarid, TIF_lat_flipud); % Ensure latitude is flipped if necessary
    netcdf.putVar(ncid_yearly, precVarid, Yearly2nc_rot90); % Write yearly data
    
    % Set attributes for the variables
    netcdf.putAtt(ncid_yearly, lonVarid, 'standard_name', 'longitude');
    netcdf.putAtt(ncid_yearly, lonVarid, 'units', 'degrees_east');
    netcdf.putAtt(ncid_yearly, lonVarid, 'axis', 'X');
    
    netcdf.putAtt(ncid_yearly, latVarid, 'standard_name', 'latitude');
    netcdf.putAtt(ncid_yearly, latVarid, 'units', 'degrees_north');
    netcdf.putAtt(ncid_yearly, latVarid, 'axis', 'Y');
    
    netcdf.putAtt(ncid_yearly, precVarid, 'long_name', 'annual TWR');
    netcdf.putAtt(ncid_yearly, precVarid, 'units', 'mm/year');
    netcdf.putAtt(ncid_yearly, precVarid, 'missing_value', 'nan');
    
    % Add global attributes
    netcdf.putAtt(ncid_yearly, netcdf.getConstant('NC_GLOBAL'), 'Title', ...
        'ChinaWR: High-Resolution (1 km) Long-Term Gridded Water Resources Dataset for China');
    netcdf.putAtt(ncid_yearly, netcdf.getConstant('NC_GLOBAL'), 'Data Period', '1980-2020');
    netcdf.putAtt(ncid_yearly, netcdf.getConstant('NC_GLOBAL'), 'Author', ...
        'Dr. Ling Zhang, Email: zhanglingky@lzb.ac.cn, Northwest Institute of Eco-Environment and Resources, CAS');
    
    % Close the NetCDF file
    netcdf.close(ncid_yearly);
    
    % Clear variables for the next loop
    clear Yearly_Col Yearly2nc_rot90 Yearly2nc;
end
